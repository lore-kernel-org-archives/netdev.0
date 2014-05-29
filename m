From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Scaling 'ip addr add' (was Re: What's the right way to use a
 *large* number of source addresses?)
Date: Thu, 29 May 2014 09:34:29 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1405290853530.1636@ja.home.ssi.bg>
References: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Niels_M=C3=B6ller?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33057 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757073AbaE2Gex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 02:34:53 -0400
In-Reply-To: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 27 May 2014, sowmini varadhan wrote:

> For Niels script, since there are many addresses in the same
> subnet, we'll have a lot of cases of an IFA_F_SECONDARY address,
> so fib_add_ifaddr will then do another walk of the ifa_list.
> 
> Has anyone looked at consolidating some of this?
> All of this could easily become a factor when the system
> has a large number of interfaces and addresses, and the
> control plane only wants to modify a very small subset of
> that state.

	First improvment without adding fields to
struct in_ifaddr would be (step 1):

- find_matching_ifa:
	- walk inet_addr_lst and match

- devinet_ioctl:
	- tryaddrmatch: walk inet_addr_lst and match

- inet_rtm_deladdr:
	- if IFA_LOCAL is provided find ifa_local in
	inet_addr_lst, then do other matches

	With additional pointer we can optimize
__inet_insert_ifa and __inet_del_ifa: we will know
how after finding ifa by walking inet_addr_lst to reach
the primary ifa: with new pointer ifa_parent that
points to our subnet. All secondaries for the subnet
can be known with pointer to the first one: ifa_sec,
because all secondaries are after all primaries:

- pri1
- pri2
- ...
- sec1_1
- sec1_2
- sec2_1
- sec2_2

	In fact ifa_sec and ifa_parent can be one field:
ifa_pri_sec, ifa_link or another better name, used depending
on IFA_F_SECONDARY.

	So, step 2: add pointer in ifa

	The real pain is fib_del_ifaddr: for ifa_local
we have a fast way (inet_addr_lst hash table) to determine
if this is the last local address in system (for prefsrc
purposes) but for ifa_broadcast we don't have such hash table.
May be with such hash table we can solve the problem but
it needs more ifa fields.

	Step 3: hash table for ifa_broadcast and
struct hlist_node for ifa_has_brd (ifa_broadcast),
ifa_hash_brd0 (first addr in subnet), ifa_hash_brd1 (last
addr in subnet).

	Any ideas?

Regards

--
Julian Anastasov <ja@ssi.bg>
