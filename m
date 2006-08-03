From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: problems with e1000 and jumboframes
Date: Thu, 3 Aug 2006 08:57:36 -0700
Message-ID: <41b516cb0608030857h1d55820rfd4ccd0cc56dd71d@mail.gmail.com>
References: <44D1FEB7.2050703@arndnet.de> <20060803135925.GA28348@2ka.mipt.ru>
	 <44D20A2F.3090005@arndnet.de> <20060803150330.GB12915@2ka.mipt.ru>
	 <Pine.LNX.4.64.0608031705560.8443@bizon.gios.gov.pl>
	 <20060803151631.GA14774@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Krzysztof Oledzki" <olel@ans.pl>,
	"Arnd Hannemann" <arnd@arndnet.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:13719 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S932548AbWHCP5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 11:57:38 -0400
Received: by wr-out-0506.google.com with SMTP id i21so565411wra
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2006 08:57:38 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <20060803151631.GA14774@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/3/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> > Strange, why this skb_shared_info cannon be added before first alignment?
> > And what about smaller frames like 1500, does this driver behave similar
> > (first align then add)?
>
> It can be.
> Could attached  (completely untested) patch help?

Note that e1000 uses power of two buffers because that's what the
hardware supports.  Also, there's no program able MTU - only a single
bit for "long packet enable" that disables frame length checks when
using jumbo frames.  That means that if you tell the e1000 it has a
16k buffer, and a 16k frame shows up on the wire, it's going to write
to the entire 16k regardless of your 9k MTU setting.  If a 32k frame
shows up, two full 16k buffers get written to (OK, assuming the frame
can fit into the receive FIFO)

That's why I've always been against trying to optimize the allocation
sizes in the driver, even with your small change the skb_shinfo area
can get corrupted.  It may be unlikely, because the frame still has to
be valid, but some switches aren't real picky about what sized frame
they'll forward on if you enable jumbo support either.  So any box on
the LAN could send you larger than MTU frames in an attempt to corrupt
memory.

I believe that if you tell a hardware device it has a buffer of a
certain size, you need to be prepared for that entire buffer to get
written to.  Unfortunately that means wasteful allocations for e1000
if a single buffer per frame is going to be used.

- Chris
