From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Wed, 23 May 2012 18:12:10 +0200
Message-ID: <1337789530.3361.2992.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
	 <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
	 <1337272654.3403.20.camel@edumazet-glaptop>
	 <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>
	 <1337678759.3361.147.camel@edumazet-glaptop>
	 <1337679045.3361.154.camel@edumazet-glaptop>
	 <1337699379.1698.30.camel@kjm-desktop.uk.level5networks.com>
	 <1337703170.3361.217.camel@edumazet-glaptop>
	 <1337704382.1698.53.camel@kjm-desktop.uk.level5networks.com>
	 <1337705135.3361.226.camel@edumazet-glaptop>
	 <1337720076.3361.667.camel@edumazet-glaptop>
	 <1337766246.3361.2447.camel@edumazet-glaptop>
	 <1337774978.3361.2744.camel@edumazet-glaptop>  <4FBD0A85.4040407@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kieran Mansley <kmansley@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49224 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932538Ab2EWQMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 12:12:16 -0400
Received: by eeit10 with SMTP id t10so2159711eei.19
        for <netdev@vger.kernel.org>; Wed, 23 May 2012 09:12:14 -0700 (PDT)
In-Reply-To: <4FBD0A85.4040407@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-23 at 09:04 -0700, Alexander Duyck wrote:
> On 05/23/2012 05:09 AM, Eric Dumazet wrote:
> > On Wed, 2012-05-23 at 11:44 +0200, Eric Dumazet wrote:
> >
> >> I believe that as soon as ixgbe can use build_skb() and avoid the 1024
> >> bytes overhead per skb, it should go away.
> >
> > Here is the patch for ixgbe, for reference.
> I'm confused as to what this is trying to accomplish.
> 
> Currently the way the ixgbe driver works is that we allocate the
> skb->head using netdev_alloc_skb, which after your recent changes should
> be using a head frag.  If the buffer is less than 256 bytes we have
> pushed the entire buffer into the head frag, and if it is more we only
> pull everything up to the end of the TCP header.  In either case if we
> are merging TCP flows we should be able to drop one page or the other
> along with the sk_buff giving us a total truesize addition after merge
> of ~1K for less than 256 bytes or 2K for a full sized frame.
> 
> I'll try to take a look at this today as it is in our interest to have
> TCP performing as well as possible on ixgbe.

With current driver, a MTU=1500 frame uses :

sk_buff (256 bytes)
skb->head : 1024 bytes  (or more exaclty now : 512 + 384)
one fragment of 2048 bytes

At skb free time,  one kfree(sk_buff) and two put_page().

After this patch :

sk_buff (256 bytes)
skb->head : 2048 bytes 

At skb free time, one kfree(sk_buff) and only one put_page().

Note that my patch doesnt change the 256 bytes threshold: Small frames
wont have one fragment and their use is :

sk_buff (256 bytes)
skb->head : 512 + 384 bytes 
