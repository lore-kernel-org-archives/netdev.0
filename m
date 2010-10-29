From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/1] RFC: poll/select performance on datagram sockets
Date: Fri, 29 Oct 2010 22:20:14 +0200
Message-ID: <1288383614.2680.10.camel@edumazet-laptop>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
	 <1288380431.2680.3.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1010291306390.8517@davide-lnx1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1010291306390.8517@davide-lnx1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 29 octobre 2010 =C3=A0 13:08 -0700, Davide Libenzi a =C3=A9=
crit :

> Yeah, epoll does check for event hints coming with the callback wakeu=
p,=20
> and avoid waking up epoll_wait() waiters, for non matching events.
> Most of the devices we care about, have been modified to report the e=
vent=20
> mask with the wakeup call.

Alban test program is _very_ pathological :

All the time is consumed in do_select() because of false sharing betwee=
n
two tasks.

We can probably rearrange variables in do_select() to make this false
sharing less problematic. I am taking a look at this.

Events: 3K cycles
+     26.14%  uclient  [kernel.kallsyms]  [k] do_raw_spin_lock         =
    =20
+     21.11%  uclient  [kernel.kallsyms]  [k] do_select                =
    =20
+     13.38%  uclient  [kernel.kallsyms]  [k] pollwake                 =
    =20
+      9.22%  uclient  [kernel.kallsyms]  [k] unix_dgram_poll          =
    =20
+      5.24%  uclient  [kernel.kallsyms]  [k] unix_peer_get            =
    =20
+      3.04%  uclient  [kernel.kallsyms]  [k] _raw_spin_unlock_irqresto=
re  =20
+      3.03%  uclient  [kernel.kallsyms]  [k] task_rq_lock             =
    =20
+      2.85%  uclient  [kernel.kallsyms]  [k] do_raw_spin_unlock       =
    =20
+      1.84%  uclient  [kernel.kallsyms]  [k] try_to_wake_up           =
    =20
+      1.55%  uclient  [kernel.kallsyms]  [k] fget_light               =
    =20
+      1.34%  uclient  [kernel.kallsyms]  [k] core_kernel_text         =
    =20


annotate :

   5.66 :        410fb342:       85 ff                   test   %edi,%e=
di                 =20
    0.00 :        410fb344:       74 1f                   je     410fb3=
65 <do_select+0x3d5>=20
    0.13 :        410fb346:       85 b5 6c fd ff ff       test   %esi,-=
0x294(%ebp)         =20
    0.00 :        410fb34c:       74 17                   je     410fb3=
65 <do_select+0x3d5>=20
         :                                                        res_o=
ut |=3D bit;          =20
    0.00 :        410fb34e:       09 b5 5c fd ff ff       or     %esi,-=
0x2a4(%ebp)         =20
         :                                                        retva=
l++;                =20
    0.00 :        410fb354:       83 85 64 fd ff ff 01    addl   $0x1,-=
0x29c(%ebp)         =20
         :                                                        wait =
=3D NULL;             =20
    0.00 :        410fb35b:       c7 85 7c fd ff ff 00    movl   $0x0,-=
0x284(%ebp)         =20
    0.00 :        410fb362:       00 00 00                             =
                    =20
         :                                               }           =20
         :                                                if ((mask & P=
OLLEX_SET) && (ex & bit)) {
   43.27 :        410fb365:       85 d2                   test   %edx,%=
edx                =20
    0.00 :        410fb367:       0f 84 f3 fe ff ff       je     410fb2=
60 <do_select+0x2d0>
    0.00 :        410fb36d:       85 b5 74 fd ff ff       test   %esi,-=
0x28c(%ebp)        =20
    0.00 :        410fb373:       0f 84 e7 fe ff ff       je     410fb2=
60 <do_select+0x2d0>
         :                                                        res_e=
x |=3D bit;          =20
    0.00 :        410fb379:       09 b5 58 fd ff ff       or     %esi,-=
0x2a8(%ebp)        =20
         :                                if (all_bits =3D=3D 0) {  =20
         :                                        i +=3D __NFDBITS;
         :                                        continue;
         :                                }
