From: Alexander Potapenko <glider@google.com>
Subject: [bug][tipc] Too short struct tipc_subscr passed to tipc_subscrb_rcv_cb()
Date: Wed, 27 Sep 2017 14:15:39 +0200
Message-ID: <CAG_fn=WegzttX52Jq8n52dOxHww8Prgdwnh5_D9kfWVy-nQTTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="94eb2c0d1b3e123aca055a2ac035"
Cc: Networking <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>, ying.xue@windriver.com,
        jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:54021 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750854AbdI0MPm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 08:15:42 -0400
Received: by mail-ua0-f180.google.com with SMTP id t36so8312620uah.10
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 05:15:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--94eb2c0d1b3e123aca055a2ac035
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi all,

I've spotted the following bug in TIPC server code while fuzzing it
with KMSAN and syzkaller:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BUG: KMSAN: use of uninitialized memory in tipc_subscrb_rcv_cb+0x14a/0xc20
CPU: 2 PID: 29 Comm: kworker/u8:1 Not tainted 4.13.0+ #3150
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/201=
1
Workqueue: tipc_rcv tipc_recv_work
Call Trace:
 __dump_stack lib/dump_stack.c:16
 dump_stack+0x172/0x1c0 lib/dump_stack.c:52
 kmsan_report+0x145/0x3d0 mm/kmsan/kmsan.c:943
 __msan_warning_32+0x66/0xb0 mm/kmsan/kmsan_instr.c:477
 htohl net/tipc/subscr.c:66
 tipc_subscrb_rcv_cb+0x14a/0xc20 net/tipc/subscr.c:333
 tipc_receive_from_sock+0x369/0x540 net/tipc/server.c:273
 tipc_recv_work+0xbe/0x1c0 net/tipc/server.c:546
 process_one_work+0xf9e/0x1ad0 kernel/workqueue.c:2097
 worker_thread+0xefd/0x2090 kernel/workqueue.c:2231
 kthread+0x499/0x620 kernel/kthread.c:232
 ret_from_fork+0x22/0x30 arch/x86/entry/entry_64.S:425
origin:
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 kmsan_save_stack_with_flags mm/kmsan/kmsan.c:302
 kmsan_internal_poison_shadow+0xb3/0x1b0 mm/kmsan/kmsan.c:198
 kmsan_kmalloc+0x80/0xe0 mm/kmsan/kmsan.c:337
 kmem_cache_alloc+0x1e2/0x220 mm/slub.c:2756
 tipc_receive_from_sock+0xff/0x540 net/tipc/server.c:257
 tipc_recv_work+0xbe/0x1c0 net/tipc/server.c:546
 process_one_work+0xf9e/0x1ad0 kernel/workqueue.c:2097
 worker_thread+0xefd/0x2090 kernel/workqueue.c:2231
 kthread+0x499/0x620 kernel/kthread.c:232
 ret_from_fork+0x22/0x30 arch/x86/entry/entry_64.S:425
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
(see the reproducer attached).

Here the user sends 16 bytes via sendmsg(), which the kernel attempts
to treat as a struct tipc_subscr. Because the actual size of a struct
is bigger, we end up touching uninitialized fields.

What is the best way to fix this?

I think it's too late to check for |len| in tipc_subscrb_rcv_cb()
(http://elixir.free-electrons.com/linux/latest/source/net/tipc/subscr.c#L32=
0),
because we'll probably need to call tipc_subscrp_cancel(s, subscriber)
in order to cancel the subscription, which is a bad idea since |s| is
invalid.
We could check that ret >=3D sizeof(struct tipc_subscr) in
tipc_receive_from_sock()
(http://elixir.free-electrons.com/linux/v4.8/source/net/tipc/server.c#L273)=
,
but this function is agnostic to the type of the data received by the
callback, so we'd better not hardcode the size there.
Shall we add an integer field (or yet another callback) to tipc_server, may=
be?

On a related note, something is wrong with the
tipc_receive_from_sock()'s return value.
First, the user appears to receive a positive value (16 in our case)
regardless of what tipc_receive_from_sock() returns.
Second, the branch at
http://elixir.free-electrons.com/linux/v4.8/source/net/tipc/server.c#L288
is never taken.

WBR,

Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--94eb2c0d1b3e123aca055a2ac035
Content-Type: text/x-csrc; charset="US-ASCII"; name="tipc_subscrb_rcv_cb-kmsan.c"
Content-Disposition: attachment; filename="tipc_subscrb_rcv_cb-kmsan.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j82z54uw0

Ly8gYXV0b2dlbmVyYXRlZCBieSBzeXprYWxsZXIgKGh0dHA6Ly9naXRodWIuY29tL2dvb2dsZS9z
eXprYWxsZXIpCgojaW5jbHVkZSA8YXJwYS9pbmV0Lmg+CiNpbmNsdWRlIDxsaW51eC90aXBjLmg+
CiNpbmNsdWRlIDxzdHJpbmcuaD4KCmludCBtYWluKCkKewogIGludCBzb2NrID0gc29ja2V0KEFG
X1RJUEMsIFNPQ0tfU0VRUEFDS0VULCAwKTsKICBzdHJ1Y3Qgc29ja2FkZHJfdGlwYyBhZGRyOwog
IG1lbXNldCgmYWRkciwgMCwgc2l6ZW9mKGFkZHIpKTsKICBhZGRyLmZhbWlseSA9IEFGX1RJUEM7
CiAgYWRkci5hZGRydHlwZSA9IFRJUENfQUREUl9OQU1FOwogIGFkZHIuYWRkci5uYW1lLm5hbWUu
dHlwZSA9IDE7CiAgYWRkci5hZGRyLm5hbWUubmFtZS5pbnN0YW5jZSA9IDE7CiAgc3RydWN0IHRp
cGNfc3Vic2NyIHN1YnNjcjsKICBtZW1zZXQoJnN1YnNjciwgMCwgc2l6ZW9mKHN1YnNjcikpOwog
IHN0cnVjdCBpb3ZlYyBpb3Y7CiAgaW92Lmlvdl9iYXNlID0gJnN1YnNjcjsKICBpb3YuaW92X2xl
biA9IHNpemVvZihzdWJzY3IpIC0gMTI7CiAgc3RydWN0IG1zZ2hkciBoZHI7CiAgbWVtc2V0KCZo
ZHIsIDAsIHNpemVvZihoZHIpKTsKICBoZHIubXNnX25hbWUgPSAmYWRkcjsKICBoZHIubXNnX25h
bWVsZW4gPSBzaXplb2YoYWRkcik7CiAgaGRyLm1zZ19pb3YgPSAmaW92OwogIGhkci5tc2dfaW92
bGVuID0gMTsKICBzZW5kbXNnKHNvY2ssICZoZHIsIDApOwogIHJldHVybiAwOwp9Cg==
--94eb2c0d1b3e123aca055a2ac035--
