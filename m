From: Zacco <zacco@fw.hu>
Subject: Re: many sockets, slow sendto
Date: Wed, 21 Mar 2007 22:53:13 +0100
Message-ID: <4601A949.2000005@fw.hu>
References: <E1HObHK-0000WB-00@osiris.swi.hu>	<20070306182039.GJ25760@galon.ev-en.org>	<45FF185B.4070007@fw.hu> <20070319.161611.70218081.davem@davemloft.net> <4600592E.80605@fw.hu> <460064C6.5030302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, baruch@ev-en.org,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta01.mail.t-online.hu ([195.228.240.50]:50003 "EHLO
	mta01.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965055AbXCUVwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 17:52:43 -0400
In-Reply-To: <460064C6.5030302@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
>
> Currently, udp_hash[UDP_HTABLE_SIZE] is using a hash function based on 
> dport number only.
>
> In your case, as you use a single port value, all sockets are in a 
> single slot of this hash table :
> To find the good socket, __udp4_lib_lookup() has to search in a list 
> with thousands of elements. Not that good, isnt it ? :(
>
So, my worry is confirmed then. But how could that delay disappear when 
splitting the sender and receiver on distinct hosts? Even in that case 
the good socket must be found somehow.
> As udp_hash is protected by a single rw_lock, I guess we could convert 
> the hash table to a RB-tree, with a key being : (dport, daddr)
>
Actually, the source address would be more important in my case, as my 
clients (each with different IP address) wants to connect to the same 
server, i.e. to the same address and port.
I think, the current design is fair enough for server implementations 
and for regular clients. But even though my application is not tipical, 
as far as I know (but it can be important with the fast performance 
growth of regular PCs), the make-up should be general enough to cope 
with special circumstances, like mine. My initial idea was to somehow 
include the complete socket pair, i.e. source address:port and 
destination address:port, keeping in mind that it should work for both 
IPv4 and IPv6. Maybe it's an overkill, I don't know.
> At lookup time, we could do :
>
> 1) A full lookup with (dport, daddr)
> 2) if not found, a lookup with wildcard : (dport, 0)
>
> I dont know if this is OK, because I dont know if it is possible to 
> have several UDP sockets with the same (dport, daddr)
Definitely, it is.
>
> It would be more scalable. But still the rw_lock is not very SMP 
> friendly...
>
Do you think there is interest in such a modification? If so, how could 
we go on with it?

thx: Zacco
