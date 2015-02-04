From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Invalid timestamp? causing tight ack loop (hundreds of
 thousands of packets / sec)
Date: Wed, 04 Feb 2015 00:03:06 -0800
Message-ID: <1423036986.907.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAO-X30uMA7=DTm5KqqvYC5RVTM0bg9pKBO1nX1+6x_2pF_fWfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: Avery Fay <avery@mixpanel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:45188 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932820AbbBDIDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 03:03:07 -0500
Received: by mail-ie0-f169.google.com with SMTP id rl12so236960iec.0
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 00:03:07 -0800 (PST)
In-Reply-To: <CAO-X30uMA7=DTm5KqqvYC5RVTM0bg9pKBO1nX1+6x_2pF_fWfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-03 at 22:50 -0800, Avery Fay wrote:
> Hello,
> 
> Let me say first: if there's a better place to ask this, please point
> me in that direction.
> 
> We've been having huge packets / sec spikes in the past few days.
> After some investigation, it looks like single connections are getting
> stuck in a loop (see tcpdump below). Each "stuck" connection will
> generate about 200kpps. It looks like our side is rejecting packets
> with "packets rejects in established connections because of timestamp"
> from netstat -s (internally PAWSEstab counter) and then generating an
> additional packet that we send out. All of these connections originate
> from georgia tech, but so far (not completely verified) it doesn't
> seem like there's any pattern to the client/os other than the fact
> that they're trying to make an https request to us.
> 
> As a temporary countermeasure, we've disabled net.ipv4.tcp_timestamps,
> which solves the immediate problem.
> 
> Our server is 174.36.240.86 running Ubuntu 12.04 with kernel 3.13.0-35-generic
> 
> The client is 128.61.57.205 and in this case almost certainly has user
> agent (we found successful requests 10 seconds before the tcpdump with
> same ip): Dalvik/2.1.0 (Linux; U; Android 5.0; XT1095
> Build/LXE22.46-11)
> 
> Beginning of tcpdump:

...

> 
> At this point, it just repeats until some timeout is hit. I haven't
> timed it, but probably one or two minutes.
> 
> I guess I have a few questions:
> 
> 1.) What's going on here? It looks like maybe there's some packet loss
> and then connection termination gets stuck in a loop because the
> client timestamp went down?
> 2.) Is there a better way to mitigate this other than disabling
> tcp_timestamps or blocking gatech ips?
> 3.) Is this our problem (ok, obviously our problem since we're
> affected but...), a kernel problem, or a gatech problem?
> 
> I'd really appreciate any help on this,

Would you have a pcap file instead ?

It looks a middlebox is broken, I dont think Android could possibly send
a frame with no payload, but with Push flag.

Neal has some patches that add a rate limiting on DACKS, that we might
upstream. (per socket rate limiting of 2 DACK per second)

Thanks
