From: "mohamed Abbas" <mabbashome@gmail.com>
Subject: d80211 and SMP issues
Date: Fri, 22 Dec 2006 14:17:19 -0800
Message-ID: <6f2b01960612221417u2af34543u4d0e8870a36f1eb9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:44405 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbWLVWRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Dec 2006 17:17:21 -0500
Received: by ug-out-1314.google.com with SMTP id 44so3099045uga
        for <netdev@vger.kernel.org>; Fri, 22 Dec 2006 14:17:20 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
Sorry if you receive this email twice, my email is acting a little weird.
I was looking at SMP issues in d80211 stack, below in my finding.
I  did  change the d80211 stack to  add SMP safety code. I will email
these patches later after I update them with what ever feedback I will
get back.

The D80211 stack has many entry points; this could leads to race
conditions and use of invalid pointers. This document will point out
the shared data between all threads which can run concurrently.

D80211 threads and entry points.
1- Wireless handler callback functions. We don't need to protect these
   functions from each other since each function touches different data.

2- net_device callback functions. The only one we have to worry about
   is hard_start_xmit which runs in software interrupt context.

3- timers, d80211 uses three timers. Below is a list of all function
   names of these timers:
* ieee80211_stat_refresh timer function. It is SMP safe and appropriate
  locks are used to protect shared data.
* sta_info_cleanup timer function. It is SMP safe and appropriate locks
  are used to protect shared data.
* ieee80211_scan_start timer function. N/A

4- Work queue. Below is a list of all callback functions used by work
   queues.
* ieee80211_sta_work function. This function is the heart beat that
  monitors the state of the connection. It uses shared data with other
  threads that need to be protected.  Inside this function it calls the
  appropriate function according to the state.  These functions are
  supposed to be mutually exclusive, however they are also called from
  other threads. We need partial locking in these function to keep a
  valid state across concurrent execution. A new spinlock called
  local->ifsta_state_lock was added to protect state's shared data.
* ieee80211_sta_scan_work. This function is SMP safe.
* sta_info_proc_add_task, this function is SMP safe.

5- export functions of d80211. Most of these functions are SMP safe
   except ieee80211_beacon_get which shares data that can be touched by
   other threads concurrently.

6- tasklet functions. There are two tasklet functions used by D80211.
   These are:
* ieee80211_tx_pending tasklet is used to transfer pending Tx frames.
  It uses the same route as hard_start_xmit, so any fix in
  hard_start_xmit should apply to it.
* ieee80211_tasklet_handler tasklet is used as the Rx route. It uses
  shared data with other threads.

Data to protect
We have two types of shared data to protect. Shared pointers need to be
protected. The thread that is going to set a pointer needs to lock the
access, change or allocate pointer then unlock. The thread that is going
to access this pointer needs to lock it first, check pointer if it is a
valid to use, use the pointer.  It must keep the lock for as long as it
is using the pointer, then unlock.  The other shared data type is
groups of data that are used together, like essid and essid_length.
These groupings must be locked any time any part of that data is
used or changed by any thread.


Shared data
The only shared data we need to protect are the members of these
structures:

* local, ifdata bss and sta.

We use ifsta_data_lock to protect these shared data.

ifsta->assocreq_ies
ifsta->assocreq_ies_len
ifsta->assocresp_ies
ifsta->assocresp_ies_len
ifsta->bssid
ifsta->auth_alg
ifsta->ssid_len
ifsta->ssid
ifsta->assocresp_ies
ifsta->probe_resp
ifsta->auth_algs
ifsta->extra_ie
ifsta->extra_ie_len
sdata->u.ap.generic_elem
sdata->u.ap.beacon_head
sdata->u.ap.beacon_tail
ifsta->auth_transaction
local->curr_rates
local->phymode

local->sta_scanning
This shared data is touched by two functions:
* ieee80211_sta_req_scan and ieee80211_scan_completed

These functions are called from different threads. The lock in these
functions is to protect from two scan requests invoked at the same time
(protecting the scan state from a race condition)

Data we did not protect:
sdata->fragments
sdata->fragment_next
pending_packet

We don't need to lock these because the data is only used and changed
from the one Rx thread.

State shared data.
We use ifsta_state_lock to protect state shared data which is used to
identify the state of the connection and association steps. This is also
used to prevent mutual exclusive functions to run at the same time in
these sections.

The sections where state shared data are changed:
ifsta->auth_alg
ifsta->auth_tries
ifsta->assoc_tries;
sdata->u.sta.associated
sdata->u.sta.authenticated

Shared data of ieee80211_sta_bss structure is protected by using
local->sta_bss_lock lock. We needed to add a lock in
ieee80211_rx_bss_info function where we change and allocate its
members. The same lock is used to protect reader thread of this data
in ieee80211_sta_scan_result function.

Is anything above incorrect? What other locking issues are people
looking to have resolved before merging?

Thanks
Mohamed
