From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG in netxen_release_tx_buffers when TSO enabled on kernels
 >= 3.3 and <= 3.6
Date: Tue, 22 Jan 2013 05:32:04 -0800
Message-ID: <1358861524.3464.3768.camel@edumazet-glaptop>
References: <1659861.dHpGAGoXHj@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:33851 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703Ab3AVNcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 08:32:08 -0500
Received: by mail-pb0-f53.google.com with SMTP id un1so3326607pbc.12
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 05:32:07 -0800 (PST)
In-Reply-To: <1659861.dHpGAGoXHj@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 11:15 +0100, Christoph Paasch wrote:
> Hello,
> 

Hi Christoph

> I have a scenario where I can trigger a bug on kernels >= 3.3 and <= 3.6. 
> Thus, I can produce it with the latest longterm-stable v3.4.26.
> 
> The crashdumps/warning can be seen below. Sometimes it is only the warning, 
> sometimes it also produces the crash. But, it happens each time I try out my 
> scenario.
> 
> 
> How to reproduce the bug (I have HP Proliant DL165 machines with HP NC375T 1Gb 
> interface):
> 
>  * Launch an iperf-session ( -t 10 ) to a server over a 1Gbps interface.
> 
>  * After 5 seconds on the client, remove the IP-address from the interface
> with ip addr del dev [itf] [ip]
> 
>  * Wait 10 more seconds and kill the iperf on the client and the server.
> 
>  * Then do: ifconfig down [itf]
> 
> Now the crash happens.
> 
> What I observe in netxen_release_tx_buffers is that upon the 18th iteration (j 
> == 17), buffrag->length == 0. buffrag->frag_count is 18.
> Sometimes (much more rare), buffrag->length rather looks like garbage (e.g., > 
> 2^32)
> 
> 
> I bisected this, and it was introduced by commit 9d4dde521577 (net: only use a 
> single page of slop in MAX_SKB_FRAGS). 
> It was fixed by Eric in commit 5640f7685831 (net: use a per task frag 
> allocator) since kernel > 3.6.
> 

Its a side effect of this patch, as it permits to build a full TSO
packet using 2 or 3 frags, instead of 16 to 17 frags.

But you could theoretically still hit the bug if the application uses
several sockets and does short write() on them. Because each short
write() would use a small frag.

> As this bug is present in the longterm-stable 3.4, should Eric's patch be 
> backported?

I don't think so. It had some side effects that we are still sorting
out. (see recent splice() fixes for example)

> If not, does somebody (with more knowledge than I have of this part of the 
> code) can have a look at it, or maybe give me a pointer on how I could solve 
> this properly?
> 
> Reverting commit 9d4dde521577 (net: only use a single page of slop in 
> MAX_SKB_FRAGS) fixes it for me on 3.4.26.
> 

Something doesn't properly test MAX_SKB_FRAGS, we should track it and
fix.
