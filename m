From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: Network kernel panics with wireless-testing 3.4-rc7
Date: Tue, 29 May 2012 09:01:43 +0200
Message-ID: <1338274903.4342.12.camel@jlt3.sipsolutions.net>
References: <4FBB0A5E.4010007@lwfinger.net>
	 (sfid-20120522_053920_311858_AA3718FE)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4FBB0A5E.4010007-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> (sfid-20120522_053920_311858_AA3718FE)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-05-21 at 22:39 -0500, Larry Finger wrote:
> I am getting kernel panics on one of my boxes from the b43legacy driver due to a 
> "Fatal exception in interrupt".
> 
> This particular one happened 50K seconds after bootup, but it has happened 
> nearly as soon as the network connection was completed. The hand-transcribed 
> traceback is as follows:

FWIW, if you have a digital camera I'm happy with a picture too, no need
to hand-transcribe everything.

> __nefif_schedule+0x13/0xa0
> ieee80211_propagate_queue_wake+0x166/0x1c0
> __ieee80211_wake_queue+0x13b/0x2d0
> ? __ieee80211_wake_queue++0xc0/0x2d0
> ieee80211_wake_queue_by_reason+0x45/0x70
> ieee80211_wake_queue+0xb/0x10
> b43legacy_dma_handle_txstatus+0x3f9/0x4b0
> ? _raw_spin_unlock+0x26/0x40
> b43legacy_handle_txstatus+0x64/0x90
> b43legacy_handle_hwtxstatus+0x66/0x70
> b43legacy_dma_rx+0x354/0x610
> 
> The offsets are for an x86_64 architecture.
> 
> These crashes never happen when I use a USB device running the rtl8187 driver, 
> thus it appears to arise in b43legacy. Any suggestions on what might cause the 
> problem would be helpful. Sorry I don't have the register dumps, etc.

Maybe that device simply never stops/wakes the queues in the same way.
Or the difference is that b43legacy has only a single queue available to
it (right now) and no QoS.

> The code dump at the point of the crash is as follows:
> ec 10 4c 89 65 f8 48 89 5d f0 49 89 fc <3c> 0f ba af 80 00 00 00 00

Hmm. That decodes (script/decodecode) to

All code
========
   0:	ec                   	in     (%dx),%al
   1:	10 4c 89 65          	adc    %cl,0x65(%rcx,%rcx,4)
   5:	f8                   	clc    
   6:	48 89 5d f0          	mov    %rbx,-0x10(%rbp)
   a:	49 89 fc             	mov    %rdi,%r12
   d:*	3c 0f                	cmp    $0xf,%al     <-- trapping instruction
   f:	ba af 80 00 00       	mov    $0x80af,%edx
	...

which is odd because that function doesn't seem to have a comparison to
0xf (15) in it as far as I can tell.

I'm pretty stumped. Does this reproduce well? Maybe you can print out
the queue number in the propagate wake function?

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
