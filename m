From: "Jarrad Waterloo" <jwaterloo@dynamicquest.com>
Subject: Adding Packet to Network Queue
Date: Fri, 22 Aug 2008 10:00:47 -0400
Message-ID: <001701c9045f$79f51980$d00414ac@quest.dynamicquest.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dqmail.dynamicquest.com ([74.202.150.200]:49220 "EHLO
	dqmail.dynamicquest.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbYHVOab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 10:30:31 -0400
Received: from jwaterloo (unknown [172.20.4.208])
	by dqmail.dynamicquest.com (Postfix) with ESMTP id 164AA2708045
	for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 10:00:49 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How do I add a packet to the network queue preferably if I am not a network
driver? I have found the function netif_rx but I am unsure if that is the
function I should be calling. Further I don't know sk_buff how to properly
initialize the sk_buff structure that has dozens of parameters. Following is
my code that throws a Segmentation fault whenever netif_rx. The variable
test1 is my packet. It does not have a frame header since it isn't coming
from a device. The first 20 bytes is the IP part of the packet. The next 8
bytes is for UDP and the last byte confirms to the DAYTIME protocol.

	printk(KERN_ALERT "device_write\n");
	printk(KERN_ALERT "%s:%d\n", __FUNCTION__, __LINE__);
	char test1[] = {0x45, 0x00, 0x00, 0x1d, 0x00, 0x00, 0x40, 0x00,
0x40, 0x11, 0x3c, 0xce, 0x7f, 0x00, 0x00, 0x01, 0x7f, 0x00, 0x00, 0x01,
0xcd, 0x54, 0x00, 0x0d, 0x00, 0x09, 0xfe, 0x1c, 0x00};
//	char test1b[] = {0x00, 0x00, 0x03, 0x04, 0x00, 0x06, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x45, 0x00, 0x00, 0x1d,
0x00, 0x00, 0x40, 0x00, 0x40, 0x11, 0x3c, 0xce, 0x7f, 0x00, 0x00, 0x01,
0x7f, 0x00, 0x00, 0x01, 0xcd, 0x54, 0x00, 0x0d, 0x00, 0x09, 0xfe, 0x1c,
0x00};
	char test2[] = {0x45, 0x00, 0x00, 0x35, 0x00, 0x00, 0x40, 0x00,
0x40, 0x11, 0x3c, 0xb6, 0x7f, 0x00, 0x00, 0x01, 0x7f, 0x00, 0x00, 0x01,
0x00, 0x0d, 0xcd, 0x54, 0x00, 0x21, 0xfe, 0x34, 0x54, 0x75, 0x65, 0x20,
0x41, 0x75, 0x67, 0x20, 0x31, 0x39, 0x20, 0x31, 0x31, 0x3a, 0x32, 0x35,
0x3a, 0x30, 0x36, 0x20, 0x32, 0x30, 0x30, 0x38, 0x0a};
//	char test2b[] = {0x00, 0x00, 0x03, 0x04, 0x00, 0x06, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x45, 0x00, 0x00, 0x35,
0x00, 0x00, 0x40, 0x00, 0x40, 0x11, 0x3c, 0xb6, 0x7f, 0x00, 0x00, 0x01,
0x7f, 0x00, 0x00, 0x01, 0x00, 0x0d, 0xcd, 0x54, 0x00, 0x21, 0xfe, 0x34,
0x54, 0x75, 0x65, 0x20, 0x41, 0x75, 0x67, 0x20, 0x31, 0x39, 0x20, 0x31,
0x31, 0x3a, 0x32, 0x35, 0x3a, 0x30, 0x36, 0x20, 0x32, 0x30, 0x30, 0x38,
0x0a};
	len = sizeof(test1);
	printk(KERN_ALERT "%s:%d\n", __FUNCTION__, __LINE__);
	struct sk_buff *skb = dev_alloc_skb(len);// + NET_IP_ALIGN
	unsigned char* data = NULL;
	int intret = 0;
	if(skb == NULL)
	{
		printk(KERN_ALERT "dev_alloc_skb: Could not allocate skb of
%d bytes.\n", len);
		return -ENOMEM;//EFAULT;
	}
	printk(KERN_ALERT "%s:%d\n", __FUNCTION__, __LINE__);
	data = skb_put(skb, len);
	if(data == NULL)
	{
		dev_kfree_skb(skb);
		printk(KERN_ALERT "skb_put: Could not extend user data area
by an additional %d bytes.\n", len);
		return -ENOMEM;//EFAULT;
	}
	//if(copy_from_user(data, buff, len))
	//{
	//	dev_kfree_skb(skb);
	//	return -EFAULT;
	//}
	printk(KERN_ALERT "%s:%d\n", __FUNCTION__, __LINE__);
	memcpy(data, test1, len);
	skb->protocol = htons(ETH_P_IP);
	printk(KERN_ALERT "%s:%d\n", __FUNCTION__, __LINE__);
	intret = netif_rx(skb);// Segmentation fault
	switch(intret)
	{
	case NET_RX_SUCCESS:
		printk(KERN_ALERT "no congestion\n");
		break;
	case NET_RX_CN_LOW:
		printk(KERN_ALERT "low congestion\n");
		break;
	case NET_RX_CN_MOD:
		printk(KERN_ALERT "moderate congestion\n");
		break;
	case NET_RX_CN_HIGH:
		printk(KERN_ALERT "high congestion\n");
		break;
	case NET_RX_DROP:
		printk(KERN_ALERT "packet was dropped\n");
		break;
	default:
		printk(KERN_ALERT "Unknown netif_rx return value\n");
		break;
	}
	return len;

