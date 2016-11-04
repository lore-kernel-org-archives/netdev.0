From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Fri, 4 Nov 2016 11:24:09 +0200
Message-ID: <20161104112409.6277b7b0@halley>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
        <20161103094239.13ac8ac2@pixies>
        <274982955.93728733.1478178387534.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, jtluka@redhat.com,
        hannes@stressinduktion.org
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34819 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751294AbcKDJYO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 05:24:14 -0400
Received: by mail-wm0-f46.google.com with SMTP id a197so37798353wmd.0
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 02:24:13 -0700 (PDT)
In-Reply-To: <274982955.93728733.1478178387534.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 3 Nov 2016 09:06:27 -0400 (EDT) Lance Richardson <lrichard@redhat.com> wrote:
> I'm not sure what could be added that would help, was there something
> specific you had in mind?

How about something like this (preliminary, feel free to massage):

@@ -248,10 +248,16 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 
 	/* Slowpath -  GSO segment length is exceeding the dst MTU.
 	 *
-	 * This can happen in two cases:
-	 * 1) TCP GRO packet, DF bit not set
-	 * 2) skb arrived via virtio-net, we thus get TSO/GSO skbs directly
-	 * from host network stack.
+	 * This can happen in several cases:
+	 *  - Forwarding of TCP GRO packet, DF bit not set
+	 *  - Forwarding of skb arrived in a virtualization environment (from
+	 *    virtio-net/vhost/tap) with TSO/GSO size set by other's network
+	 *    stack
+	 *  - Local GSO skb xmitted on an NETIF_F_TSO tunnel stacked over an
+	 *    interface with a smaller mtu
+	 *  - Arriving GRO skb (or GSO skb in a virtualized env) that gets L2
+	 *    bridged to a NETIF_F_TSO tunnel stacked over an interface with an
+	 *    insufficent mtu
 	 */
 	features = netif_skb_features(skb);
 	BUILD_BUG_ON(sizeof(*IPCB(skb)) > SKB_SGO_CB_OFFSET);
