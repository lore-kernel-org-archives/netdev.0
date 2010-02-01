From: "Lv Zheng" <lv.zheng@soliton.com.cn>
Subject: socket layer incorrectness
Date: Mon, 1 Feb 2010 13:05:45 +0800
Message-ID: <1C8BCB3F488645A99B76E803ED3BD094@lzheng>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.94.1.90] ([203.94.1.90]:14179 "EHLO C150.SPAMMAIL.COM"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751092Ab0BAFRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 00:17:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all

I'm new to this mailing list. Please forgive me if this mail is
interrupting you.

I read the kernel socket layer implementation recently.
Wondering whether one can kindly make some detailed explaination
for me, I sent this email to the netdev mailing list. 

==================================================

I noted BSD had presented socket API as follows:

socket(family, type, protocol)

Which means there should be sth. like:
sock_register_family
sock_register_type
sock_register_protocol
in the world.

As far as these abstractions are concerned, struct sock should be:
struct sock {
    struct family_ops *family_ops;
    struct sock_type_ops *type_ops;
    struct proto_ops *proto_ops;
};

==================================================

A. family abstaction
For family, I think it looks like a protocol factory, and owns
create/release ops might be enough for family_ops just like current
kernel does.

B. type abstaction
For type, we have SOCK_STREAM, SOCK_DGRAM, SOCK_RAW
for INET:
1. SOCK_STREAM: buffer requeued orderly for the upper level
   protocol layer without lower level protocol's head/tail.
2. SOCK_DGRAM: buffer defrag/fraged aligning lower level
   protocol's content due to lower level's MTU without lower level
   protocol's head/tail.
3. SOCK_RAW: buffer is copied directly from lower level queue.
   If socket is implemented in this way, defrag/frag/streaming can go
   into the socket layer and we can involve hardware as much as it
   could to accelarate fragmentation and streaming.

But currently we do not have type abstraction in the Linux kernel.

C. protocol abstaction
For protocol, we have proto_register in the kernel, but it does not
affect sock_create. In the socket layer, only /proc/net/protocols is
affected by such registration, proto_ops is mostly a family specific
implementation.

proto_ops should not related to the socket operations which should
be type_ops' responsibility while current kernel takes proto_ops as
type_ops.

IMO, proto_ops should contain operations as head/tail analysis,
buffer ordering determination and so on.

==================================================

Can someone tell me why current Linux kernel is not implemented in
the way that BSD socket abstraction tells us to do?

Best regards/Lv Zheng
