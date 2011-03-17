From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: sctp panic
Date: Thu, 17 Mar 2011 12:20:18 +0100
Message-ID: <AANLkTi=yN2MtaOwUQsKmYaYxfkc0+mKtZiDeJ=r-KACK@mail.gmail.com>
References: <20110317074356.231320@gmx.net>
	<AANLkTim2cggAu6o7iU74S47xyFfOqrSiUPOfo+2XoidB@mail.gmail.com>
	<20110317104903.153050@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: walter schloegl <sctp@muskelshirt.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110317104903.153050@gmx.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 17, 2011 at 11:49 AM, walter schloegl <sctp@muskelshirt.de>=
 wrote:
>
> -------- Original-Nachricht --------
>> Datum: Thu, 17 Mar 2011 08:56:47 +0100
>> Von: richard -rw- weinberger <richard.weinberger@gmail.com>
>> An: sctp@muskelshirt.de
>> CC: linux-kernel@vger.kernel.org
>> Betreff: Re: sctp panic
>
>> On Thu, Mar 17, 2011 at 8:43 AM, =A0<sctp@muskelshirt.de> wrote:
>> > Hi
>> >
>> > when doing the actions below I get a panic.
>> >
>> > - echo 1 > /proc/sys/net/sctp/addip_enable
>> > - In a C-Programm
>> > =A0 =A0- socket(AF_INET,SOCK_STREAM,IPPROTO_SCTP);
>> > =A0 =A0- connect(....) =A0 =A0 (with correct filled parameters)
>> >
>> > Its no process (waiting in accept) neccessary
>>
>> Can you show us the panic message and your C prorgam?
>> This would help reproducing the panic...
>
> The C-Code is:
>
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <netdb.h>
> #include <stdio.h>
> #include <errno.h>
> #include <unistd.h>
> #include "sctp.h"
>
>
> int
> main(int ac,char **av)
> {
>
> =A0int s;
> =A0char *remhost;
> =A0int port;
> =A0struct hostent *hp;
> =A0struct sockaddr_in server;
>
> =A0if (ac !=3D 3) {
> =A0 =A0 =A0printf("usage: %s ip-addr port\n",av[0]);
> =A0 =A0 =A0exit(1);
> =A0}
>
> =A0remhost =3D av[1];
> =A0port =3D atoi(av[2]);
>
>
> =A0server.sin_port =3D htons(port);
> =A0server.sin_family =3D AF_INET;
> =A0hp =3D gethostbyname(remhost);
> =A0if (hp =3D=3D 0) =A0{
> =A0 =A0 fprintf(stderr,"unknown host %s\n",remhost);
> =A0 =A0 exit(1);
> =A0}
> =A0memcpy((char *)&server.sin_addr,(char *)hp->h_addr,hp->h_length);
>
> =A0if ((s =3D socket(AF_INET,SOCK_STREAM,IPPROTO_SCTP)) < 0) =A0{
> =A0 =A0 =A0fprintf(stderr,"socket IPPROTO_SCTP proc %d =A0failed errn=
o %d\n",getpid(),errno);
> =A0 =A0 =A0close(s);
> =A0 =A0 =A0exit(1);
> =A0}
>
> =A0if (connect(s,(struct sockaddr *)&server,sizeof server) < 0) =A0 =A0=
 =A0 =A0{
> =A0 =A0 =A0 =A0 fprintf(stderr,"connect failed errno %d\n",errno);
> =A0 =A0 =A0 =A0 close(s);
> =A0 =A0 =A0 =A0 exit(1);
> =A0}
> }
>
> The crash says:
>
> crash> bt
> PID: 14646 =A0TASK: ffff8801f40c7560 =A0CPU: 9 =A0 COMMAND: "x"
> =A0#0 [ffff8801f6f5f6f0] machine_kexec at ffffffff8103697b
> =A0#1 [ffff8801f6f5f750] crash_kexec at ffffffff810b9078
> =A0#2 [ffff8801f6f5f820] oops_end at ffffffff814cc900
> =A0#3 [ffff8801f6f5f850] die at ffffffff8101733b
> =A0#4 [ffff8801f6f5f880] do_trap at ffffffff814cc1d4
> =A0#5 [ffff8801f6f5f8e0] do_invalid_op at ffffffff81014ee5
> =A0#6 [ffff8801f6f5f980] invalid_op at ffffffff81013f5b
> =A0 =A0[exception RIP: skb_over_panic+93]
> =A0 =A0RIP: ffffffff81404bdd =A0RSP: ffff8801f6f5fa38 =A0RFLAGS: 0001=
0296
> =A0 =A0RAX: 0000000000000083 =A0RBX: 0000000000000040 =A0RCX: 0000000=
0000013f6
> =A0 =A0RDX: 0000000000000000 =A0RSI: 0000000000000046 =A0RDI: 0000000=
000000246
> =A0 =A0RBP: ffff8801f6f5fa58 =A0 R8: ffffffff818a3da0 =A0 R9: 0000000=
000000000
> =A0 =A0R10: 0000000000000001 =A0R11: 0000000000000000 =A0R12: ffff880=
1f4e11000
> =A0 =A0R13: 0000000000000004 =A0R14: 000000000000003e =A0R15: 0000000=
000000001
> =A0 =A0ORIG_RAX: ffffffffffffffff =A0CS: 0010 =A0SS: 0018
> =A0#7 [ffff8801f6f5fa60] skb_put at ffffffff81405c1c
> =A0#8 [ffff8801f6f5fa80] sctp_addto_chunk at ffffffffa0503c23
> =A0#9 [ffff8801f6f5fad0] sctp_make_init at ffffffffa0506705
> #10 [ffff8801f6f5fba0] sctp_sf_do_prm_asoc at ffffffffa04f81d4
> #11 [ffff8801f6f5fbd0] sctp_do_sm at ffffffffa04fd381
> #12 [ffff8801f6f5fd60] sctp_primitive_ASSOCIATE at ffffffffa0513daf
> #13 [ffff8801f6f5fd80] __sctp_connect at ffffffffa0510f09
> #14 [ffff8801f6f5fe50] sctp_connect at ffffffffa0511248
> #15 [ffff8801f6f5fe80] inet_dgram_connect at ffffffff81471b6c
> #16 [ffff8801f6f5feb0] sys_connect at ffffffff813ff747
> #17 [ffff8801f6f5ff80] system_call_fastpath at ffffffff81013172
> =A0 =A0RIP: 0000003015ee2150 =A0RSP: 00007fffea7bdce8 =A0RFLAGS: 0001=
0206
> =A0 =A0RAX: 000000000000002a =A0RBX: ffffffff81013172 =A0RCX: 0000000=
000000000
> =A0 =A0RDX: 0000000000000010 =A0RSI: 00007fffea7bdd00 =A0RDI: 0000000=
000000003
> =A0 =A0RBP: 00007fffea7bdd40 =A0 R8: 0000000000759020 =A0 R9: ff00000=
000000000
> =A0 =A0R10: 00007fffea7bda70 =A0R11: 0000000000000246 =A0R12: 0000000=
000000000
> =A0 =A0R13: 00007fffea7bde20 =A0R14: 00000000004006e0 =A0R15: 0000000=
000000000
> =A0 =A0ORIG_RAX: 000000000000002a =A0CS: 0033 =A0SS: 002b
>
>
> One more Info:
> When calling my programm with 127.0.0.1 as remote ip-addr I get a:
> connect failed errno 111
>
> When calling it with a "non local" address (and also no "accept proce=
ss" running) I get the Panic.
>
>
>>
>> > br
>> > walter
>> > --
>> > GMX DSL Doppel-Flat ab 19,99 Euro/mtl.! Jetzt mit
>> > gratis Handy-Flat! http://portal.gmx.net/de/go/dsl
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-ke=
rnel"
>> in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.ht=
ml
>> > Please read the FAQ at =A0http://www.tux.org/lkml/
>> >
>>
>> --
>> Thanks,
>> //richard
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kern=
el" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>
> --
> NEU: FreePhone - kostenlos mobil telefonieren und surfen!
> Jetzt informieren: http://www.gmx.net/de/go/freephone
>

CC'ing netdev

--=20
Thanks,
//richard
