From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: VXLAN RCU error
Date: Fri, 24 Feb 2017 11:40:12 -0800
Message-ID: <20170224114012.0755d8c6@cakuba.netronome.com>
References: <20170222142745.31c5f75e@cakuba.netronome.com>
        <20170222203031.45513e4c@cakuba.netronome.com>
        <20170223002025.2d2d3c4e@laptop>
        <CAM_iQpWuXzNHNiwjX0V8FrEaPMHsaYX-Tm3QKHJqTxLuKqZ1xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Pravin B Shelar <pshelar@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:38445 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751265AbdBXTkf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Feb 2017 14:40:35 -0500
In-Reply-To: <CAM_iQpWuXzNHNiwjX0V8FrEaPMHsaYX-Tm3QKHJqTxLuKqZ1xA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Feb 2017 11:30:05 -0800, Cong Wang wrote:
> On Thu, Feb 23, 2017 at 12:20 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
> >
> > Ugh.  Looks like this may not work even if it makes the splat go away.
> > synchronize_net() doesn't seem to wait for the _bh() flavor of RCU, so
> > we need to add syncronize_rcu_bh() call before freeing the socket or do
> > a normal rcu_read_lock()/unlock() on the fast path.  Any RCU experts
> > want to comment? :)  
> 
> But rcu_read_lock_bh() is enforced by upper layer, __dev_queue_xmit(),
> I am afraid you can't change it.
> 
> Does changing these kfree() to kfree_rcu() work too since there is no
> kfree_rcu_bh()?

If I read the code correctly the VXLAN/GENEVE does standard RCU
dereferencing (i.e. non-_bh()) but as you point out __dev_queue_xmit()
takes rcu_read_lock_bh() and not rcu_read_lock() so we either have to
make VXLAN code take the correct lock itself or make VXLAN
reconfiguration code do synchronize_rcu_bh() as well as
synchronize_net() (most likely with synchronize_rcu_mult() but then
we will have to open code expediting under rtnl...)  

I was waiting for some internal reviews but let me just post the code I
have now implementing the first option.
