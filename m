From: Bertrand Guay-Paquet <bernie@step.polymtl.ca>
Subject: skb_clone slower than copying skb data
Date: Mon, 02 Aug 2004 10:13:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410E4C16.6070604@step.polymtl.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I am writing a patch for the usbnet driver to add support for the 
Prolific PL2501 USB host-to-host cable. My question is entirely related 
to netdev business however, so please read on.

In order to achieve Win32 interropability, the driver needs to receive 
up to 6 ethernet packets wrapped up in a single skb. My current 
implementation for reading the contained individual packets is: 
(simplified to show relevant parts)

for (each packet in skb except last one) {
	length = packet_length();

	if (!(skb2 = alloc_skb(length, GFP_ATOMIC)))
		return -ENOMEM;

	//Copy the data related to the current ethernet packet
	memcpy(skb_put(skb2, length), skb->data, length);

	//Jump to next ethernet packet
	skb_pull(skb, length);
	netif_rx(skb2);
}
//Process last packet
netif_rx(skb);
==========

This works very well but uses unnecessary memory for the memcpy. I then 
tried: (again simplified to show relevant parts):

for (each packet in skb except last one) {
	length = packet_length();

	if (!(skb2 = skb_clone(skb, GFP_ATOMIC)))
		return -ENOMEM;

	//Copy the data related to the current ethernet packet
	skb_trim(skb2, length);

	//Jump to next ethernet packet
	skb_pull(skb, length);
	netif_rx(skb2);
}
//Process last packet
netif_rx(skb);
==========

This works as well, but the throughput is cut in half. How can this be 
so? Is skb_clone combined with netif_rx supposed to be so slow? I have 
searched other uses of skb_clone and have not found any similar to mine 
so I do not know if this is normal behaviour or not. I have tried using 
skb_clone with 2.4.26 and 2.6.7 with the same results.

Any help would be greatly appreciated!

Bertrand
