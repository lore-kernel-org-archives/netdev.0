From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC] IPsec performance improvements (discussion base for the IPsec performance BoF)
Date: Thu, 4 Feb 2016 07:36:53 +0100
Message-ID: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36677 "EHLO
	h-62.96.220.36.host.de.colt.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756482AbcBDHFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:05:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds some performance improvements for IPsec. It is a
early stage RFC version and still contains bugs. I post this now just
to have a discussion base for the IPsec performance BoF at the netdev
conference next week.

The patchset adds a GRO/GSO codepath for IPsec and tries to avoid the
linearization of the buffers whenever possible.

The GRO part seems to work well. GSO and avoiding linearization still
have problems, in particular with async crypto operations.

Below are some performance numbers.

Transport mode (measured by Sowmini Varadhan):

Baseline:

2.6 Gbps ESP-NULL
2.17 Gbps AES-GCM-256

Avoid frame copy + GSO/GRO:

8 Gbps ESP-NULL
4.2 Gbps AES-GCM-256

Forwarding with tunnel mode (measured by myself):

Baseline:

3.63 Gbps prcypt(echainiv(authenc(hmac(sha1-ssse3),cbc-aes-aesni)))

Avoid frame copy + GSO/GRO:

4.33 Gbps pcrypt(echainiv(authenc(hmac(sha1-ssse3),cbc-aes-aesni)))

I used the following cpu bindings for the pcrypt setup:

----------  TCP   ----------  ESP Tunnel     ---------   TCP   ----------
|iperf -c|------->|IPsec TX|---------------->|IPsec RX|------->|iperf -s|
----------        ----------                 ----------        ----------

cpu0           RX |        |              RX |        |
cpu1              |        | TX              |        | TX
cpu2              | crypto |                 | crypto |
cpu3              | crypto |                 | crypto |
cpu4              | crypto |                 | crypto |
cpu5              | crypto |                 | crypto |

Packet forwarding is done with four machines.
The crypto operations are isolated from the networking path.
Packets traverse the stack as follows:

- Packet is received on cpu0 (irqs pinned).
- cpu0 enqueues the crypto request to a pcrypt parallelization queue.
- Crypto is done on cpu 2-5, crypto requests are pinned round robin
  to the cpus. pcrypt ensures to keep the requests in the right order.
- After crypto is done, the requests are queued to a pcrypt
  serialization queue.
- cpu1 gets a callback from the crypto layer and does the final TX
  path.
