From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: IGMP Join dropping multicast packets
Date: Wed, 18 Mar 2009 10:24:18 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0903181016120.5116@jbrandeb-desk1.amr.corp.intel.com>
References: <91bdcedb0903141316j2dbf4160wb348a5a9e3bde8ad@mail.gmail.com>  <49BC69D5.5000002@cosmosbay.com>  <91bdcedb0903151904x1066ac24h63557b588e7c4967@mail.gmail.com>  <49BEA1ED.4010907@cosmosbay.com>
 <91bdcedb0903172050td2ef895he48168987ad94472@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jesse.brandeburg@intel.com, e1000-devel@lists.sourceforge.net
To: Dave Boutcher <daveboutcher@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32983 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082AbZCRRYX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 13:24:23 -0400
In-Reply-To: <91bdcedb0903172050td2ef895he48168987ad94472@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Mar 2009, Dave Boutcher wrote:
> Eric, based on your inability to recreate this, I tried on some other
> hardware I had lying around that has an AMD chipset built-in NIC.
> I could not recreate the problem on that hardware.  I'm starting to
> think this is an e1000 problem.  In both the e1000 and e1000e
> drivers they do the following logic:
> 
>       /* clear the old settings from the multicast hash table */
> 
>        for (i = 0; i < mta_reg_count; i++) {
>                E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
>                E1000_WRITE_FLUSH();
>        }
> 
>        /* load any remaining addresses into the hash table */
> 
>        for (; mc_ptr; mc_ptr = mc_ptr->next) {
>                hash_value = e1000_hash_mc_addr(hw, mc_ptr->da_addr);
>                e1000_mta_set(hw, hash_value);
>        }
> 
> There's clearly a window where the NIC doesn't have the multicast
> addresses loaded.  This may just be broken-as-designed.  If anyone
> else happens to have some e1000 hardware and wants to see if you
> can recreate this, I'd be curious.
> 
> Some other notes just FYI...
> 
> - RcvbufErrors in /proc/net/snmp doesn't get incremented when this happens
> - there are no messages in dmesg
> - frames get dropped when the program calls exit() and all the sockets
> get closed
>   (and multicast joins dropped) as well as when the ADD_MEMBERSHIPs happen
> - The problem happens even when adding a sleep(1) in between each of the
>   ADD_MEMBERSHIP calls.

Interesting, this code has been there for eons (and probably this 
behavior) but that doesn't mean its not a problem.

We are in the process of figuring out if there are any hardware corner 
cases to changing this code (particularly in e1000)

Initial thoughts are:
1) kcalloc an array that we then populate with the hash functions, and 
   then program every location only once (never flush)
2) only program a single hash value each time a multicast is added (bad 
   because we can't tell the difference in the list since the last time 
   the OS gave us the list)

It really seems like this should be fixable, and I agree that the driver 
behavior is far from optimal, however well entrenched.

Jesse
