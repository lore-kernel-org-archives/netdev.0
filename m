From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [Bugme-new] [Bug 13692] New: dccp_ipv4 has >1 usage count and
	cannot be removed
Date: Fri, 3 Jul 2009 21:41:43 +0200
Message-ID: <20090703194143.GA9410@gerrit.erg.abdn.ac.uk>
References: <bug-13692-10286@http.bugzilla.kernel.org/> <20090702151807.aa5b8447.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, oakad@yahoo.com,
	dccp@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:40190 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758769AbZGCTmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jul 2009 15:42:24 -0400
Content-Disposition: inline
In-Reply-To: <20090702151807.aa5b8447.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > http://bugzilla.kernel.org/show_bug.cgi?id=13692
| > 
| >            Summary: dccp_ipv4 has >1 usage count and cannot be removed
<snip>
| > 
| > Upon loading of dccp_ipv4 (either through autoload or explicitly, with
| > modprobe) the usage count of the module is immediately set to 2 and the module
| > can not be unloaded.
| > 
| > Usage count seems to be correctly incremented/decremented during operation, but
| > never gets lower than 2.
| > 
I am not sure that this should be treated as a bug. DCCP has a control
socket which causes extra reference counts. The above issue, however, is
harmless, since dccp_ipv4 can be removed with "rmmod -f", as shown in
the trace below.

On the contrary, this provides protection against accidental removal.
The module can safely be removed when all timewait sockets have been
released. Someone wishing to unload the module should be aware of this
possibility and ensured, via 'ss -dane', that no more sockets are used.

In a very early version of DCCP (~ 2005 .. 2006) there used to be an
"unload hack" kernel config option:

config IP_DCCP_UNLOAD_HACK
         depends on IP_DCCP=m && IP_DCCP_CCID3=m
         bool "DCCP control sock unload hack"
         ---help---
           Enable this to be able to unload the dccp module when the it
           has only one refcount held, the control sock one. Just execute
           "rmmod dccp_ccid3 dccp"
 
           Just say N.
==> The last sentence also seems to capture the mailing list consensus;
    the question whether to reinstate the unload hack came up several
    times but was not met with widespread approval.

In summary, if a user knows what s/he is doing, it is possible to safely
unload dccp_ipv{4,6} when DCCP is compiled as a module.

Originally the unload option was there mainly to allow work on the
modules, there was even one suggestion to completely disable module
unloading.

I believe that the current state provides some protection against
accidental/unwanted removal by unsuspecting users. Arnaldo, what
do you think?

Here is the trace (and it worked like this for the past 4 years):
  ~ $ lsmod
  Module                  Size  Used by

  ~ $ modprobe -v dccp_ipv4 
  insmod /lib/modules/2.6.31-rc1/kernel/net/dccp/dccp.ko 
  insmod /lib/modules/2.6.31-rc1/kernel/net/dccp/dccp_ipv4.ko 

  ~ $ lsmod
  Module                  Size  Used by
  dccp_ipv4              14856  2 
  dccp                  102984  1 dccp_ipv4

  ~ $ rmmod -f dccp_ipv4
  ~ $ lsmod
  Module                  Size  Used by
  dccp                  102984  0 
  ~ $ rmmod dccp
  ~ $ lsmod
  Module                  Size  Used by
