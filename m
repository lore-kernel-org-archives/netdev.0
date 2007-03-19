From: Zacco <zacco@fw.hu>
Subject: Re: many sockets, slow sendto
Date: Tue, 20 Mar 2007 00:10:19 +0100
Message-ID: <45FF185B.4070007@fw.hu>
References: <E1HObHK-0000WB-00@osiris.swi.hu> <20070306182039.GJ25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Baruch Even <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta02.mail.t-online.hu ([195.228.240.51]:50152 "EHLO
	mta02.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965451AbXCSXJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 19:09:54 -0400
In-Reply-To: <20070306182039.GJ25760@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Baruch and all,

As you recommended, I used oprofile and it turned out that the 
__udp4_lib_lookup function spent most of the time. There is a udp hash 
table and the sockets are sought based on the 7 LSBs of the destination 
port number. So what happened is now quite obvious: I had many thousands 
of sockets, all with the same destination port, thus linked in the same 
slot of this hash table. I tried using different ports and it
was much faster then.

As the hash table seems to be about the proc fs, I tried to compile a 
kernel without that. I could start that kernel only with the 
init=/bin/bash option, otherwise many things did not work. My program 
stopped right after sending out the first packet, so the proc fs must be 
essential to the receive operation (but it might have been something 
else, too). If it is so, do you think I can remove the proc fs 
dependency that I can still use the regular socket functions (i.e. 
socket, connect, listen, send, recv etc)?

Now, I also understand why this receive related function is called right 
in the dev_queue_xmit function, where also some softirq happens, and 
both the send and receive part resided on the same host. As soon as I 
ran the test on two hosts, separating the send and receive sides, the 
considerable send delay simply disappeared. Could you help me to 
understand why? I expected the delay to appear on the receiving side, 
but it didn't.

The connection setup part (socket+connect) however still lineraly 
increased with the number of sockets. Hopefully, I can send you the 
oprofile result of this part, too, but in case you already have any idea 
of how I can get rid of this dependency, please, let me know!

thx a lot: Zacco

