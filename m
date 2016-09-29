From: Jay Smith <jay@kentik.com>
Subject: UDP wierdness around skb_copy_and_csum_datagram_msg()
Date: Wed, 28 Sep 2016 17:18:09 -0700
Message-ID: <CAA3=++__5iwkyyCvSCWJS_b=pBXg=CTYikGgLSh40dkDaY82vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a113bd5e29d5c76053d9a69d5
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:36623 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752463AbcI2ASK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 20:18:10 -0400
Received: by mail-it0-f53.google.com with SMTP id u134so81680118itb.1
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 17:18:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a113bd5e29d5c76053d9a69d5
Content-Type: text/plain; charset=UTF-8

I've spent the last week or so trying to track down a recurring
problem I'm seeing with UDP datagram handling.  I'm new to the
internals of the Linux network stack, but it appears to me that
there's a substantial error in recent kernels' handling of UDP
checksum errors.

The behavior I'm seeing:  I have a UDP server that receives lots of
datagrams from many devices on a single port. A small number of those
devices occasionally send packets with bad UDP checksums.  After I
receive one of these bad packets, the next recvmsg() made on the
socket returns data from the bad-checksum packet, but the
source-address and length of the next (good) packet that arrived at
the port.

I believe this issue was introduced between linux 3.18 and 3.19, by a
set of changes to net/core/datagram.c that made
skb_copy_and_csum_datagram_msg() and related functions use the
iov_iter structure to copy data to user buffers.  In the case where
those functions copy a datagram and then conclude that the checksum is
invalid, they don't remove the already-copied data from the user's
iovec; when udp_recvmsg() calls skb_copy_and_csum_datagram_msg() for a
second time, looking at the next datagram on the queue, that second
datagram's data is appended to the first datagram's.  So when
recvmsg() returns to the user, the return value and msg_name reflect
the second datagram, but the first bytes in the user's iovec come from
the first (bad) datagram.

(I've attached a test program that demonstrates the problem.  Note
that it sees correct behavior unless the bad-checksum packet has > 68
bytes of UDP data; otherwise, the packet doesn't make it past the
CHECKSUM_BREAK test, and never enters
skp_copy_and_csum_datagram_msg().)

The fix for UDP seems pretty simple; the iov_iter's iov_offset member
just needs to be set back to zero on a checksum failure.  But it looks
like skb_copy_and_csum_datagram_msg() is also called from tcp_input.c,
where I assume that multiple sk_buffs can be copied-and-csum'd into
the same iov -- if that's right, it seems like iov_iter needs some
additional state to support rolling-back the most recent copy without
losing previous ones.

Any thoughts?

--001a113bd5e29d5c76053d9a69d5
Content-Type: text/x-csrc; charset=US-ASCII; name="csumtest.c"
Content-Disposition: attachment; filename="csumtest.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_itnlcwoi0

I2luY2x1ZGUgPHN0cmluZy5oPgojaW5jbHVkZSA8dW5pc3RkLmg+CiNpbmNsdWRlIDxuZXRkYi5o
PgojaW5jbHVkZSA8ZXJybm8uaD4KI2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIu
aD4KI2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4KI2luY2x1ZGUgPG5ldGluZXQvaW4uaD4KI2luY2x1
ZGUgPHN5cy91aW8uaD4KI2luY2x1ZGUgPGFycGEvaW5ldC5oPgoKI2luY2x1ZGUgPG5ldGluZXQv
dWRwLmg+CgoKaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKiphcmd2KQp7CiAgaW50IHJldDsKCiAg
aWYgKGFyZ2MgPCAyKSB7CiAgICBmcHJpbnRmKHN0ZGVyciwgIlVzYWdlOiBjc3VtdGVzdCA8Ynl0
ZXMtaW4tYmFkLXBhY2tldD5cbiIpOwogICAgZXhpdCgxKTsKICB9CgogIHN0cnVjdCBzb2NrYWRk
cl9pbiBhZGRyOwogIHNvY2tsZW5fdCBhZGRyTGVuID0gc2l6ZW9mKGFkZHIpOyAgCiAgYWRkci5z
aW5fZmFtaWx5ID0gQUZfSU5FVDsKICBhZGRyLnNpbl9hZGRyLnNfYWRkciA9IGluZXRfYWRkcigi
MTI3LjAuMC4xIik7CiAgYWRkci5zaW5fcG9ydCA9IGh0b25zKDApOwoKICBpbnQgbGlzdGVuID0g
c29ja2V0KEFGX0lORVQsIFNPQ0tfREdSQU0sIElQUFJPVE9fVURQKTsKICBpZiAobGlzdGVuIDwg
MCkKICB7CiAgICBmcHJpbnRmKHN0ZGVyciwgImZhaWxlZCB0byBjcmVhdGUgbGlzdGVuaW5nIHNv
Y2tldCAoZXJyPSVkOiAlcylcbiIsIGVycm5vLCBzdHJlcnJvcihlcnJubykpOwogICAgZXhpdCgx
KTsKICB9CgogIHJldCA9IGJpbmQobGlzdGVuLCAoc3RydWN0IHNvY2thZGRyICopICZhZGRyLCBh
ZGRyTGVuKTsKICBpZiAocmV0ICE9IDApCiAgewogICAgZnByaW50ZihzdGRlcnIsICJmYWlsZWQg
dG8gYmluZCBsaXN0ZW5pbmcgc29ja2V0IHNvY2tldCAoZXJyPSVkOiAlcylcbiIsIGVycm5vLCBz
dHJlcnJvcihlcnJubykpOwogICAgZXhpdCgxKTsKICB9CgogIHJldCA9IGdldHNvY2tuYW1lKGxp
c3RlbiwgKHN0cnVjdCBzb2NrYWRkciAqKSAmYWRkciwgJmFkZHJMZW4pOwogIGlmIChyZXQgIT0g
MCkKICB7CiAgICBmcHJpbnRmKHN0ZGVyciwgImdldHNvY2tuYW1lIGZhaWxlZCBmb3IgbGlzdGVu
aW5nIHNvY2tldCBzb2NrZXQgKGVycj0lZDogJXMpXG4iLCBlcnJubywgc3RyZXJyb3IoZXJybm8p
KTsKICAgIGV4aXQoMSk7CiAgfQogIGVsc2UKICB7CiAgICBwcmludGYoImxpc3RlbmluZyBvbiBw
b3J0ICVkXG4iLCBudG9ocyhhZGRyLnNpbl9wb3J0KSk7CiAgfQoKCiAgCiAgLy8gU2VuZCBhIHBh
Y2tldCB3aXRoIGRlbGliZXJhdGVseSBiYWQgY2hlY2tzdW0KICBjaGFyIHJhd0J1Zls0MDk2XTsK
ICBtZW1zZXQocmF3QnVmLCAwLCA0MDk2KTsKICBzdHJ1Y3QgdWRwaGRyICp1ZHBoID0gKHN0cnVj
dCB1ZHBoZHIgKikgcmF3QnVmOwoKICAvLyBTZW5kIGFzIFVEUCBkYXRhIHRoZSBzdHJpbmcgIkJB
RCBEQVRBIiwgcmVwZWF0ZWQgYXMgbmVjZXNzYXJ5CiAgLy8gdG8gZmlsbCB0aGUgbnVtYmVyIG9m
IGJ5dGVzIHJlcXVlc3RlZCBvbiB0aGUgY29tbWFuZC1saW5lCiAgY2hhciAqZGF0YSA9IHJhd0J1
ZiArIHNpemVvZihzdHJ1Y3QgdWRwaGRyKTsKICBpbnQgYmFkQnl0ZXMgPSBhdG9pKGFyZ3ZbMV0p
OwogIGludCBpOwogIGZvciAoaSA9IDA7IGkgPCBiYWRCeXRlczsgaSArPSA4KQogIHsKICAgIHN0
cm5jcHkoZGF0YSArIGksICJCQUQgREFUQSIsIDgpOwogIH0KCiAgLy8gVURQIGhlYWRlcnMgY29u
dGFpbiBhIGJvZ3VzIGNoZWNrc3VtLCBidXQgYXJlIG90aGVyd2lzZSByZWFzb25hYmxlCiAgdWRw
aC0+Y2hlY2sgPSBodG9ucygweGJhZGQpOwogIHVkcGgtPnNvdXJjZSA9IGh0b25zKDE4KTsKICB1
ZHBoLT5kZXN0ID0gYWRkci5zaW5fcG9ydDsKICB1ZHBoLT5sZW4gPSBodG9ucyhzaXplb2Yoc3Ry
dWN0IHVkcGhkcikgKyBiYWRCeXRlcyk7CgogIGludCByYXcgPSBzb2NrZXQoQUZfSU5FVCwgU09D
S19SQVcsIElQUFJPVE9fVURQKTsKICByZXQgPSBzZW5kdG8ocmF3LCByYXdCdWYsCgkgICAgICAg
c2l6ZW9mKHN0cnVjdCB1ZHBoZHIpICsgYmFkQnl0ZXMsIDAsCgkgICAgICAgKHN0cnVjdCBzb2Nr
YWRkciAqKSAmYWRkciwgYWRkckxlbik7CiAgaWYgKHJldCA8IDApCiAgewogICAgZnByaW50Zihz
dGRlcnIsICJyYXcgc2VuZCBmYWlsZWQgKGVycj0lZDogJXMpXG4iLCBlcnJubywgc3RyZXJyb3Io
ZXJybm8pKTsKICAgIGV4aXQoMSk7CiAgfQogIAogIAogIC8vIFNlbmQgYSBzZWNvbmQsIGxlZ2l0
aW1hdGUgVURQIHBhY2tldAogIGludCBjb29rZWQgPSBzb2NrZXQoQUZfSU5FVCwgU09DS19ER1JB
TSwgSVBQUk9UT19VRFApOwogIGNoYXIgKnNlY29uZCA9ICJHb29kIGRhdGEiOwogIHJldCA9IHNl
bmR0byhjb29rZWQsIHNlY29uZCwgc3RybGVuKHNlY29uZCksIDAsCgkgICAgICAgKHN0cnVjdCBz
b2NrYWRkciAqKSAmYWRkciwgYWRkckxlbik7CiAgaWYgKHJldCA8IDApCiAgewogICAgZnByaW50
ZihzdGRlcnIsICJzZWNvbmQgY29va2VkIHNlbmQgZmFpbGVkIChlcnI9JWQ6ICVzKVxuIiwgZXJy
bm8sIHN0cmVycm9yKGVycm5vKSk7CiAgICBleGl0KDEpOwogIH0KCiAgLy8gUmVhZCB3aGF0J3Mg
cXVldWVkIHVwIGZvciB1cy4KICB3aGlsZSAoMSkKICB7CiAgICBzdHJ1Y3QgbXNnaGRyIG1zZzsK
ICAgIHN0cnVjdCBpb3ZlYyAgaW92OwogICAgY2hhciByZWFkQnVmWzQwOTZdOwogICAgc3NpemVf
dCBieXRlczsKICAgIAogICAgbWVtc2V0KHJlYWRCdWYsIDAsIDQwOTYpOwogICAgCiAgICBpb3Yu
aW92X2Jhc2UgPSByZWFkQnVmOwogICAgaW92Lmlvdl9sZW4gPSBzaXplb2YocmVhZEJ1Zik7Cgog
ICAgbXNnLm1zZ19uYW1lID0gTlVMTDsKICAgIG1zZy5tc2dfbmFtZWxlbiA9IDA7CiAgICBtc2cu
bXNnX2lvdiA9ICZpb3Y7CiAgICBtc2cubXNnX2lvdmxlbiA9IDE7CiAgICBtc2cubXNnX2NvbnRy
b2wgPSBOVUxMOwogICAgbXNnLm1zZ19jb250cm9sbGVuID0gMDsKICAgIG1zZy5tc2dfZmxhZ3Mg
PSAwOwogICAgCiAgICBieXRlcyA9IHJlY3Ztc2cobGlzdGVuLCAmbXNnLCAwKTsKICAgIGlmIChi
eXRlcyA8IDApCiAgICB7CiAgICAgIGZwcmludGYoc3RkZXJyLCAiZ2V0c29ja25hbWUgZmFpbGVk
IGZvciBsaXN0ZW5pbmcgc29ja2V0IHNvY2tldCAoZXJyPSVkOiAlcylcbiIsIGVycm5vLCBzdHJl
cnJvcihlcnJubykpOwogICAgICBleGl0KDEpOwogICAgfQoKICAgIHByaW50ZigicmVjdm1zZyBy
ZXR1cm5lZCAlbGQgYnl0ZXM6ICVzXG4iLCBieXRlcywgcmVhZEJ1Zik7CgogICAgaWYgKGJ5dGVz
ID09IDkpCiAgICAgIGJyZWFrOwogIH0KfQo=
--001a113bd5e29d5c76053d9a69d5--
