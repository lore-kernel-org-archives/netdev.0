From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: TCP port firewall controlled by UDP packets
Date: Thu, 11 Aug 2011 17:13:17 -0700
Message-ID: <20110811171317.271be88b.rdunlap@xenotime.net>
References: <1313106969-18733-1-git-send-email-as@strmilov.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tonda <as@strmilov.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy3-pub.bluehost.com ([69.89.21.8]:52658 "HELO
	oproxy3-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754632Ab1HLANU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 20:13:20 -0400
In-Reply-To: <1313106969-18733-1-git-send-email-as@strmilov.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Aug 2011 01:56:09 +0200 Tonda wrote:

Need more patch description & justification here, as well as
Signed-off-by: <your name & email address>


> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -624,3 +624,7 @@
>  	  on the Internet.
>  
>  	  If unsure, say N.
> +
> +config TCPFIREWALL
> +	tristate "TCP Firewall controlled by UDP queries"
> +	depends on m

Why buildable only as a loadable module?


> diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
> --- a/net/ipv4/Makefile
> +++ b/net/ipv4/Makefile
> @@ -51,3 +51,4 @@
>  
>  obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
>  		      xfrm4_output.o
> +obj-$(CONFIG_TCPFIREWALL) += tcpfirewall/
> diff --git a/net/ipv4/tcpfirewall/Makefile b/net/ipv4/tcpfirewall/Makefile
> --- a/net/ipv4/tcpfirewall/Makefile
> +++ b/net/ipv4/tcpfirewall/Makefile
> @@ -0,0 +1 @@
> +obj-$(CONFIG_TCPFIREWALL) += tcpfirewall.o
> diff --git a/net/ipv4/tcpfirewall/tcpfirewall.c b/net/ipv4/tcpfirewall/tcpfirewall.c
> --- a/net/ipv4/tcpfirewall/tcpfirewall.c
> +++ b/net/ipv4/tcpfirewall/tcpfirewall.c
> @@ -0,0 +1,451 @@
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/init.h>
> +#include <linux/skbuff.h>
> +#include <linux/in.h>
> +#include <linux/if_packet.h>
> +#include <linux/tcp.h>
> +#include <linux/udp.h>
> +#include <net/tcp.h>
> +#include <net/udp.h>
> +
> +struct net_protocol {
> +	int (*handler)(struct sk_buff *skb);
> +	void (*err_handler)(struct sk_buff *skb, u32 info);
> +	int (*gso_send_check)(struct sk_buff *skb);
> +	struct sk_buff *(*gso_segment)(struct sk_buff *skb,
> +		u32 features);
> +	struct sk_buff **(*gro_receive)(struct sk_buff **head,
> +		struct sk_buff *skb);
> +	int (*gro_complete)(struct sk_buff *skb);
> +	unsigned int no_policy:1,
> +		netns_ok:1;
> +};
> +
> +MODULE_LICENSE("GPL");
> +
> +static unsigned long inet_protos = 0x01234567;
> +
> +struct net_protocol **_inet_protos;
> +
> +module_param(inet_protos, ulong, 0);
> +
> +static int *otviraky;
> +static int *zaviraky;
> +
> +static int pocetotviraku;
> +static int pocetzaviraku;
> +static int stav;
> +static int packetcounter;
> +static int tcpport;
> +static int open;
> +static int firewall;
> +
> +int (*tcpv4recv) (struct sk_buff *skb);
> +int (*udprecv) (struct sk_buff *skb);
> +
> +int udpcontroller(struct sk_buff *skb)

can be static?

> +{
> +	const struct udphdr *uh;
> +
> +	if (skb->pkt_type != PACKET_HOST) {
> +		kfree_skb(skb);
> +		return 0;
> +	}
> +
> +	if (!pskb_may_pull(skb, sizeof(struct tcphdr))) {
> +		kfree_skb(skb);
> +		return 0;
> +	}
> +
> +	uh = udp_hdr(skb);
> +
> +	if (pocetotviraku == 0)
> +		return udprecv(skb);
> +
> +	if (!open) {
> +		if (uh->dest == otviraky[stav]) {
> +			++stav;
> +			packetcounter = 0;
> +
> +			if (stav == pocetotviraku) {
> +				open = 1;
> +				stav = 0;
> +			}
> +		} else {
> +			if (packetcounter <= 16) {
> +				++packetcounter;
> +				if (packetcounter > 16)
> +					stav = 0;
> +			}
> +		}
> +	} else {
> +		if (uh->dest == zaviraky[stav]) {
> +			++stav;
> +			packetcounter = 0;
> +
> +			if (stav == pocetzaviraku) {
> +				open = 0;
> +				stav = 0;
> +			}
> +		} else {
> +			if (packetcounter <= 16) {
> +				++packetcounter;
> +				if (packetcounter > 16)
> +					stav = 0;
> +			}
> +		}
> +	}
> +
> +
> +	return udprecv(skb);
> +}
> +
> +int tcpfirewall(struct sk_buff *skb)

can be static?

> +{
> +	const struct tcphdr *th;
> +
> +	if (skb->pkt_type != PACKET_HOST) {
> +		kfree_skb(skb);
> +		return 0;
> +	}
> +
> +	if (!pskb_may_pull(skb, sizeof(struct tcphdr))) {
> +		kfree_skb(skb);
> +		return 0;
> +	}
> +
> +	th = tcp_hdr(skb);
> +
> +	if (th->dest == tcpport) {
> +		if (firewall == 1 && !open) {
> +			/*tcpv4sendreset(NULL, skb);*/
> +			kfree_skb(skb);
> +			return 0;
> +		}
> +	}
> +
> +	return tcpv4recv(skb);
> +}

[snip]

> +static int __init start(void)
> +{
> +	if (inet_protos == 0x01234567) {
> +		printk(KERN_WARNING "inet_protos parameter was not");
> +		printk(KERN_WARNING " specified!\nread its value from");
> +		printk(KERN_WARNING " System_map file file, and insert");
> +		printk(KERN_WARNING " the module again!\n");

Break the printk() calls at newlines, please.

> +		return -1;
> +	}
> +
> +	pocetotviraku = 0;
> +	pocetzaviraku = 0;
> +	stav = -1;
> +	packetcounter = 0;
> +	tcpport = 0;
> +	open = 1;
> +	firewall = 0;
> +
> +	memset(&kobj, 0, sizeof(struct kobject));
> +
> +	_inet_protos = (struct net_protocol **)inet_protos;
> +
> +	kobject_init(&kobj, &khid);
> +	if (kobject_add(&kobj, NULL, "tcpfirewall") < 0)
> +		printk(KERN_ERR "kobject_add failed");
> +

All of these kobject_add() and sysfs_create_file() failures are not
fatal errors?

> +	if (sysfs_create_file(&kobj, &fw) < 0)
> +		printk(KERN_ERR "sysfs_create_file failed");
> +	if (sysfs_create_file(&kobj, &opn) < 0)
> +		printk(KERN_ERR "sysfs_create_file failed");
> +	if (sysfs_create_file(&kobj, &tcpp) < 0)
> +		printk(KERN_ERR "sysfs_create_file failed");
> +	if (sysfs_create_file(&kobj, &openers) < 0)
> +		printk(KERN_ERR "sysfs_create_file failed");
> +	if (sysfs_create_file(&kobj, &closers) < 0)
> +		printk(KERN_ERR "sysfs_create_file failed");
> +	if (sysfs_create_file(&kobj, &stat) < 0)
> +		printk(KERN_ERR "sysfs_create_file failed");
> +	if (sysfs_create_file(&kobj, &counte) < 0)
> +		printk(KERN_ERR "sysfs_create_file failed");
> +
> +	zalohatcp = _inet_protos[IPPROTO_TCP];
> +	zalohaudp = _inet_protos[IPPROTO_UDP];
> +	mytcp = *zalohatcp;
> +	myudp = *zalohaudp;
> +	tcpv4recv = mytcp.handler;
> +	udprecv = myudp.handler;
> +	mytcp.handler = tcpfirewall;
> +	myudp.handler = udpcontroller;
> +	_inet_protos[IPPROTO_TCP] = &mytcp;
> +	_inet_protos[IPPROTO_UDP] = &myudp;
> +	return 0;
> +}
> +
> +static void konec(void)
> +{
> +	_inet_protos[IPPROTO_TCP] = zalohatcp;
> +	_inet_protos[IPPROTO_UDP] = zalohaudp;
> +
> +	if (pocetotviraku)
> +		kfree(otviraky);
> +	if (pocetzaviraku)
> +		kfree(zaviraky);
> +
> +	kobject_del(&kobj);
> +}
> +
> +module_init(start);
> +module_exit(konec);
> --

Some of the function & variable names confuse me.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
