From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2] iplink: add support for num[tr]xqueues
Date: Fri, 20 Jul 2012 20:08:13 +0200
Message-ID: <20120720180813.GA1560@minipsycho.orion>
References: <lh9v01i5y1bg7t9j24kof0f8.1342799538355@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	edumazet@google.com, shemminger@vyatta.com
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:55039 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab2GTSIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:08:18 -0400
Received: by weyx8 with SMTP id x8so2812471wey.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 11:08:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <lh9v01i5y1bg7t9j24kof0f8.1342799538355@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 20, 2012 at 05:52:18PM CEST, stephen.hemminger@vyatta.com wrote:
>I like the option, but  numtxqueue is too verbose for the syntax model
>of iproute. Why not use txq and rxq?

There is "txqueuelen" present already in iplink. I tried to be uniform here.
Isn't "txq" and "rxq" rather too short? And afterall, these parameters
are not supposed to be used on daily basis by anyone :)

Jirka

>
>Sent from my ASUS Pad
>
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>---
>> include/linux/if_link.h |    2 ++
>> ip/iplink.c             |   20 ++++++++++++++++++++
>> man/man8/ip-link.8.in   |   13 +++++++++++++
>> 3 files changed, 35 insertions(+)
>>
>>diff --git a/include/linux/if_link.h b/include/linux/if_link.h
>>index 00e5868..46f03db 100644
>>--- a/include/linux/if_link.h
>>+++ b/include/linux/if_link.h
>>@@ -140,6 +140,8 @@ enum {
>> 	IFLA_EXT_MASK,		/* Extended info mask, VFs, etc */
>> 	IFLA_PROMISCUITY,	/* Promiscuity count: > 0 means acts PROMISC */
>> #define IFLA_PROMISCUITY IFLA_PROMISCUITY
>>+	IFLA_NUM_TX_QUEUES,
>>+	IFLA_NUM_RX_QUEUES,
>> 	__IFLA_MAX
>> };
>> 
>>diff --git a/ip/iplink.c b/ip/iplink.c
>>index 679091e..0baa128 100644
>>--- a/ip/iplink.c
>>+++ b/ip/iplink.c
>>@@ -48,6 +48,8 @@ void iplink_usage(void)
>> 		fprintf(stderr, "                   [ address LLADDR ]\n");
>> 		fprintf(stderr, "                   [ broadcast LLADDR ]\n");
>> 		fprintf(stderr, "                   [ mtu MTU ]\n");
>>+		fprintf(stderr, "                   [ numtxqueues QUEUE_COUNT ]\n");
>>+		fprintf(stderr, "                   [ numrxqueues QUEUE_COUNT ]\n");
>> 		fprintf(stderr, "                   type TYPE [ ARGS ]\n");
>> 		fprintf(stderr, "       ip link delete DEV type TYPE [ ARGS ]\n");
>> 		fprintf(stderr, "\n");
>>@@ -279,6 +281,8 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
>> 	int mtu = -1;
>> 	int netns = -1;
>> 	int vf = -1;
>>+	int numtxqueues = -1;
>>+	int numrxqueues = -1;
>> 
>> 	*group = -1;
>> 	ret = argc;
>>@@ -445,6 +449,22 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
>> 				invarg("Invalid operstate\n", *argv);
>> 
>> 			addattr8(&req->n, sizeof(*req), IFLA_OPERSTATE, state);
>>+		} else if (strcmp(*argv, "numtxqueues") == 0) {
>>+			NEXT_ARG();
>>+			if (numtxqueues != -1)
>>+				duparg("numtxqueues", *argv);
>>+			if (get_integer(&numtxqueues, *argv, 0))
>>+				invarg("Invalid \"numtxqueues\" value\n", *argv);
>>+			addattr_l(&req->n, sizeof(*req), IFLA_NUM_TX_QUEUES,
>>+				  &numtxqueues, 4);
>>+		} else if (strcmp(*argv, "numrxqueues") == 0) {
>>+			NEXT_ARG();
>>+			if (numrxqueues != -1)
>>+				duparg("numrxqueues", *argv);
>>+			if (get_integer(&numrxqueues, *argv, 0))
>>+				invarg("Invalid \"numrxqueues\" value\n", *argv);
>>+			addattr_l(&req->n, sizeof(*req), IFLA_NUM_RX_QUEUES,
>>+				  &numrxqueues, 4);
>> 		} else {
>> 			if (strcmp(*argv, "dev") == 0) {
>> 				NEXT_ARG();
>>diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
>>index 9386cc6..8a24e51 100644
>>--- a/man/man8/ip-link.8.in
>>+++ b/man/man8/ip-link.8.in
>>@@ -40,6 +40,11 @@ ip-link \- network device configuration
>> .RB "[ " mtu
>> .IR MTU " ]"
>> .br
>>+.RB "[ " numtxqueues
>>+.IR QUEUE_COUNT " ]"
>>+.RB "[ " numrxqueues
>>+.IR QUEUE_COUNT " ]"
>>+.br
>> .BR type " TYPE"
>> .RI "[ " ARGS " ]"
>> 
>>@@ -156,6 +161,14 @@ Link types:
>> - Ethernet Bridge device
>> .in -8
>> 
>>+.TP
>>+.BI numtxqueues " QUEUE_COUNT "
>>+specifies the number of transmit queues for new device.
>>+
>>+.TP
>>+.BI numrxqueues " QUEUE_COUNT "
>>+specifies the number of receive queues for new device.
>>+
>> .SS ip link delete - delete virtual link
>> .I DEVICE
>> specifies the virtual  device to act operate on.
>>-- 
>>1.7.10.4
>>
