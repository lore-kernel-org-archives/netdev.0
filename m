From: "George P Nychis" <gnychis@cmu.edu>
Subject: Re: Re: created new q_disc, inserted module,
	tc tells me unknown qdisc
Date: Tue, 11 Apr 2006 15:53:28 -0400 (EDT)
Message-ID: <3650.128.2.140.234.1144785208.squirrel@128.2.140.234>
References: <1707.128.2.140.234.1144719699.squirrel@128.2.140.234>
	<20060411111644.59573edc@localhost.localdomain>
	<3568.128.2.140.234.1144783610.squirrel@128.2.140.234>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
In-Reply-To: <3568.128.2.140.234.1144783610.squirrel@128.2.140.234>
To: "George P Nychis" <gnychis@cmu.edu>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

I am getting closer...

I added debugging, and noticed that it looks for:
       snprintf(buf, sizeof(buf), "%s_qdisc_util", str);

However in q_xcp.c it had:
       struct qdisc_util xcp_util =3D {

so I changed that to xcp_qdisc_util, and now i run tc:
lanthanum-ini tc # tc qdisc add dev ath0 root xcp capacity 54Mbit limit 1=
00
Segmentation fault

This happens on this line:
 q =3D dlsym(dlh, buf);

Since this is very hard for people to help me without the source code, i =
did ask the author if it has been release publically and am waiting for a=
 response.  In the meantime, it seems as though maybe instead of trying t=
o get this to work with a newer version of tc, i should install an old ve=
rsion of tc that the module was original made for.

Though if anyone else has ideas let me know.

Thanks for all the help

- George


>> On Mon, 10 Apr 2006 21:41:39 -0400 (EDT) "George P Nychis"=20
>> <gnychis@cmu.edu> wrote:
>>=20
>>> Hi,
>>>=20
>>> I am trying to install a proprietary qdisc made for research, it is
>>> not publically released yet, however its been used several times so i
>>> know it works.
>>>=20
>>> The files included are: q_xcp.c: static int xcp_parse_opt() static
>>> int xcp_print_opt() static int xcp_print_xstats() struct qdisc_util
>>> xcp_util =3D { "NULL", "xcp" ..... };
>>>=20
>>> sch_xcp.c: static int xcp_enqueue() static int xcp_requeue() static
>>> struct sk_buff * xcp_dequeue() .... .... struct Qdisc_ops
>>> xcp_qdisc_ops =3D{ NULL,NULL,"xcp",.... };
>>>=20
>>> printk(KERN_INFO "XCP qdisc module loaded.\n"); return=20
>>> register_qdisc(&xcp_qdisc_ops);
>>>=20
>>>=20
>>> So, i make everything successfully, it creates q_xcp.so and copies it
>>>  to /usr/lib and sch_xcp.o which it copies to /lib/modules/... so
>>> then I "insmod sch_xcp" and i see in dmesg: "XCP qdisc module loaded.=
"
>>>=20
>>>=20
>>> I then try: "tc qdisc add dev eth0 root xcp capacity 10Mbit limit
>>> 500" and get: "Unknown qdisc "xcp", hence option "capacity" is
>>> unparsable"
>>>=20
>>> So then I read the INSTALL further to find some sort of solution and
>>> it mentions: This again assumes "tc" version is 2.4.7.  If your "tc"
>>> is a different version, download the iproute2 source code, and edit
>>> Makefile to point "TC_INCLUDE" to "-I..../iproute2/include
>>> -I..../iproute2/tc"
>>>=20
>>> So, i did that, and i recompiled the q_xcp.so: lanthanum-ini
>>> src-1.0.1 # make q_xcp.so cc -O2 -fPIC=20
>>> -I/var/tmp/portage/iproute2-2.6.11.20050310-r1/work/iproute2-2.6.11/i
>>> nc lude/=20
>>> -I/var/tmp/portage/iproute2-2.6.11.20050310-r1/work/iproute2-2.6.11/t
>>> c_ include -o q_xcp.o -c q_xcp.c ld -shared -o q_xcp.so q_xcp.o rm -f=
=20
>>> q_xcp.o
>>>=20
>>> But i still get the same error.... so then my very final last effort=20
>>> was to move q_xcp.c to my iproute2 source code tc/ directory and
>>> added this to the makefile: TCMODULES +=3D q_xcp.o
>>>=20
>>> Then I compiled tc, and i check tc to see if the xcp qdisc functions=20
>>> were loaded: lanthanum-ini tc # nm tc | grep xcp 080531ec t
>>> xcp_parse_opt 080533e0 t xcp_print_opt 08053426 t xcp_print_xstats
>>> 08070cc0 D xcp_util
>>>=20
>>>=20
>>> And finally: lanthanum-ini tc # ./tc qdisc add dev ath0 root xcp=20
>>> capacity 54Mbit limit 500 Unknown qdisc "xcp", hence option
>>> "capacity" is unparsable
>>>=20
>>>=20
>>> I have no clue :(  I figured that putting the .so into /usr/lib would
>>>  have been enough.  Sorry for the long e-mail, I hope someone can
>>> help, and thank you for your time even if you don't know the solution
>>> but read this :)
>>>=20
>>> - George
>>>=20
>>=20
>> The .so needs to go in /usr/lib/tc (assuming you are running relativel=
y
>>  recent version of iproute2 tools).
>>=20
>> Read source to tc.c where it calls dlopen.
>>=20
>>=20
>=20
> Still didn't seem to solve the problem :\
>=20
> In my tc.c i have: snprintf(buf, sizeof(buf), "/usr/lib/tc/q_%s.so", st=
r);
>=20
>=20
> Also: lanthanum-ini tc # ls /usr/lib/tc experimental.dist  normal.dist
> pareto.dist  paretonormal.dist  q_netem.so  q_xcp.so
>=20
> And finally: lanthanum-ini tc # tc qdisc add dev ath0 root xcp capacity
> 54Mbit limit 500 Unknown qdisc "xcp", hence option "capacity" is
> unparsable
>=20
> Maybe i should add debugging in tc.c and see if it sees the .so and fai=
ls
> to load it or something.
>=20
> Any other suggestions?
>=20
> Thanks for all the responses, George
>=20
> _______________________________________________ LARTC mailing list=20
> LARTC@mailman.ds9a.nl=20
> http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc
>=20
>=20


--=20
