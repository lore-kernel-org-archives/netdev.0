From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 2/2] 6lowpan: reassembly: fix kernel oops while
 unloading
Date: Thu, 6 Mar 2014 07:09:44 +0100
Message-ID: <20140306060943.GB13676@omega>
References: <1394052211-6976-1-git-send-email-alex.aring@gmail.com>
 <1394052211-6976-3-git-send-email-alex.aring@gmail.com>
 <20140305223246.GA17526@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:55567 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbaCFGJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 01:09:48 -0500
Received: by mail-ee0-f53.google.com with SMTP id e51so880514eek.40
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 22:09:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140305223246.GA17526@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

thanks for your reply.

On Wed, Mar 05, 2014 at 11:32:46PM +0100, Florian Westphal wrote:
> Alexander Aring <alex.aring@gmail.com> wrote:
> > It seems that the inet_frag_queue is deleted but the timer is running. This
> > patch adds a for loop to iterate over all frag_queue entries in the
> > frag_bucket and calling del_timer for each frag_queue entry while
> > unloading the 6lowpan module.
> > 
> > Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> > Reported-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
> > ---
> > I am not sure about that I can do that in this simply way without hold
> > any lock of the inet_frag_queue or inet_frag_bucket. Please help there.
> > The kernel oops never occurs afterwards, but this isn't simple to test.
> > I can't test all cases.
> 
> I find it hard to believe that this is a 6lowpan specific problem,
> most likely this needs a fix in inet_fragment code.
> 
I thought that too, maybe it's a problem in the inet_fragment code.


There are two function which I call on exit:

inet_frags_fini(&lowpan_frags); - which deletes the secret_timer.
inet_frags_exit_net(&net->ieee802154_lowpan.frags, &lowpan_frags);
 - which runs a force inet_frag_evictor

maybe I forgot to call some other function to cleanup the fragmentation.

I don't saw any other exit function and I do a similar cleanup like ipv4/ipv6
and they don't have a module_exit function which is called for the
inet_fragment code. 

Example:

ipv6:

ipv6_frag_exit(); - which is only called in error branch of module_init
		    in net/ipv6/af_inet6.c.

ipv4:
I don't see that ipv4 call any of the inet_frag exit functions.


Maybe I have some special problem there because I can unload the 6lowpan
module which used the inet_fragment code.

If ipv4/ipv6 do a cleanup at shutdown, then maybe this never occurs because a
shutdown takes no longer than 60 seconds (in case of ipv6).

> I am currently looking at that code for different reasons anyway and can
> investigate tomorrow if you do not have time for it.

Ok, thanks you for that. I have time for that, but I don't believe that
I found a better solution for that issue. I will be grateful for any help!
Maybe we can find a proper solution together.

I wrote a small testscript with:

while true
do
	rmmod 6lowpan
	sleep 120
	modprobe 6lowpan
	ip link add link wpan0 name lowpan0 type lowpan
	ip link set lowpan0 up
	sleep 120
done

sleep 120 - to be sure we hit the 60 seconds timer arrivial.

I did a overnight test while run a fragmented ping from another node and
the kernel oops never occurs again. I can test some new patches again
this testscript, but this is not to be sure that it works 100%
correct.

- Alex
