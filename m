From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH] tun: don't zeroize sock->file on detach
Date: Wed, 22 Aug 2012 13:14:42 +0400
Message-ID: <5034A302.4090406@parallels.com>
References: <20120809124436.5156.26944.stgit@localhost.localdomain> <20120809.161639.1789560369123168415.davem@davemloft.net> <5033B199.6080305@parallels.com> <CADVnQy=HGxFiczXGxb4iMumKUAXt77UzTWFqFwGzpLoQjvUR7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"dhowells@redhat.com" <dhowells@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rick.jones2@hp.com" <rick.jones2@hp.com>,
	"ycheng@google.com" <ycheng@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mikulas@artax.karlin.mff.cuni.cz" <mikulas@artax.karlin.mff.cuni.cz>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADVnQy=HGxFiczXGxb4iMumKUAXt77UzTWFqFwGzpLoQjvUR7Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

21.08.2012 21:18, Neal Cardwell =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, Aug 21, 2012 at 12:04 PM, Stanislav Kinsbursky
> <skinsbursky@parallels.com> wrote:
>> 10.08.2012 03:16, David Miller =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>
>>> From: Stanislav Kinsbursky <skinsbursky@parallels.com>
>>> Date: Thu, 09 Aug 2012 16:50:40 +0400
>>>
>>>> This is a fix for bug, introduced in 3.4 kernel by commit
>>>> 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d, which, among other thing=
s,
>>>> replaced
>>>> simple sock_put() by sk_release_kernel(). Below is sequence, which=
 leads
>>>> to
>>>> oops for non-persistent devices:
>>>>
>>>> tun_chr_close()
>>>> tun_detach()                            <=3D=3D tun->socket.file =3D=
 NULL
>>>> tun_free_netdev()
>>>> sk_release_sock()
>>>> sock_release(sock->file =3D=3D NULL)
>>>> iput(SOCK_INODE(sock))                  <=3D=3D dereference on NUL=
L pointer
>>>>
>>>> This patch just removes zeroing of socket's file from __tun_detach=
().
>>>> sock_release() will do this.
>>>>
>>>> Cc: stable@vger.kernel.org
>>>> Reported-by: Ruan Zhijie <ruanzhijie@hotmail.com>
>>>> Tested-by: Ruan Zhijie <ruanzhijie@hotmail.com>
>>>> Acked-by: Al Viro <viro@ZenIV.linux.org.uk>
>>>> Acked-by: Eric Dumazet <edumazet@google.com>
>>>> Acked-by: Yuchung Cheng <ycheng@google.com>
>>>> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
>>>
>>>
>>> Applied, thanks.
>>>
>>
>> Hi, David.
>> I found out, that this commit: b09e786bd1dd66418b69348cb110f3a647646=
26a
>> was previous attempt to fix the problem.
>> I believe this commit have to be dropped.
>
> Have you tried testing with that commit reverted? AFAICT from reading
> the code, if you revert b09e786bd1dd66418b69348cb110f3a64764626a then
> the sockets_in_use count becomes incorrect, because sock_release()
> will be calling this_cpu_sub() for each tun socket teardown when ther=
e
> was no corresponding this_cpu_add() for the tun socket (because the
> tun socket is not allocated with sock_alloc()).
>
> Can you sketch in more detail why that commit should be dropped?
>

Yep, I've noticed, that first commit patch fixes two problems simultane=
ously.
Here are they:
1) Dereference of invalid SOCK_INODE()
2) sockets_in_use incorrect value.

But I believe, that introducing new SOCK_EXTERNALLY_ALLOCATED socket fl=
ag and=20
use it in generic code just to handle tun issues is overkill.
My patch solves first problem mush simpler, than mentioned commit.

About second problem...
What about this:

diff --git a/net/socket.c b/net/socket.c
index dfe5b66..dab462b 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -526,8 +526,8 @@ void sock_release(struct socket *sock)
         if (test_bit(SOCK_EXTERNALLY_ALLOCATED, &sock->flags))
                 return;

-       this_cpu_sub(sockets_in_use, 1);
         if (!sock->file) {
+               this_cpu_sub(sockets_in_use, 1);
                 iput(SOCK_INODE(sock));
                 return;
         }

?


> neal
>


--=20
Best regards,
Stanislav Kinsbursky
