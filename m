From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: Question on e1000 patch, rx-copy-break related.
Date: Thu, 4 May 2006 09:00:07 -0700
Message-ID: <4807377b0605040900y31bfaec3o73cb04c5c9a2e4e@mail.gmail.com>
References: <4457B96A.4030808@candelatech.com>
	 <4807377b0605031022s3b5bfad2x757fbd470884c6fd@mail.gmail.com>
	 <4458F2A2.60605@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: NetDev <netdev@vger.kernel.org>, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0102.google.com ([66.249.82.204]:22938 "EHLO
	wx-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1750750AbWEDQAI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 12:00:08 -0400
Received: by wx-out-0102.google.com with SMTP id t16so350391wxc
        for <netdev@vger.kernel.org>; Thu, 04 May 2006 09:00:07 -0700 (PDT)
To: "Ben Greear" <greearb@candelatech.com>
In-Reply-To: <4458F2A2.60605@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/3/06, Ben Greear <greearb@candelatech.com> wrote:
> Jesse Brandeburg wrote:
> > On 5/2/06, Ben Greear <greearb@candelatech.com> wrote:
> >
> >> In commit:  a292ca6efbc1f259ddfb9c902367f2588e0e8b0f
> >> to e1000_main.c, there is the change below.
> >>
> >> I am curious why the skb_put no longer subtracts ETHERNET_FCS_SIZE
> >> from the length.  Is the idea that we will now always include the
> >> FCS at the end of the skb?
> >
> >
> > This is a long and hairy story behind this, but there is a bit called
> > SECRC that controls hardware stripping of the CRC.  In *this* driver
> > we turned that bit on, so that we didn't have to mess with skb->len -=
> > 4 and the nasty negative unwrap if we were using multiple descriptors
> > for rx.
> >
> > Since then, we've removed multiple descriptor rx.
> >
> > And after that, I've discovered that some BMCs are very unhappy if we
> > strip CRCs using SECRC.
> >
> > So, my related question is: is it okay if we just always leave the CRC
> > on the end of the data?  It doesn't seem to harm anything.
>
> I believe it might mess up bridging logic if it tries to send the entire
> skb to a peer interface, ie cause an extra 4 bytes to be written.

hm, good point, we'll look into that.

> My personal preference is to set a flag in the skb struct indicating whether
> or not the crc is appended (and skb_put).  Then, bridging code can ignore it if needed,
> and sniffers and such can get the CRC in user-land.  To remain backwards compat,
> at least the skb-put of the crc logic should default to OFF so that we don't
> break any existing user-land bridging logic.  I have the ethtool API logic written to
> twiddle this save-crc behaviour if someone decides this is worthy of the kernel.

that seems like an excellent idea, however, finding room in the skb
struct is fun.

> > Well, its a changing picture.  I had planned to eventually enable the
> > hardware to strip the CRC if we aren't connected to some kind of
> > offboard management.  We'll get there in steps.
>
> So, as of 2.6.16.13, is the hardware stripping (SERC) enabled?  Could
> you also let me know where this bit is defined in case I want to twiddle
> it myself (a quick grep for SERC in 2.6.16.13 yields nothing.)

Yes, SECRC is enabled in 2.6.16, for both packet split and legacy
receive paths.  It will probably stay enabled for 2.6.17 too unless
the BMC communication bug is rated important enough for the change to
be made.  Unfortunately right now due to SECRC bit being set BMC
communication over SMBUS is likely broken.

Jesse
