From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter: nf_log fix
Date: Tue, 14 Apr 2009 23:07:24 +0200
Message-ID: <49E4FB0C.1080103@cosmosbay.com>
References: <20090410191736.21efab8c@mako-desktop>	 <49E4744D.5090205@trash.net>	<49E47C2D.1050508@cosmosbay.com>	 <49E47EA5.3060706@trash.net> <20090414211946.4ea0455e@mako-desktop>	 <49E4EE9C.7040509@cosmosbay.com> <1239742000.24204.9.camel@ice-age>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mariusz Kozlowski <m.kozlowski@tuxland.pl>,
	Patrick McHardy <kaber@trash.net>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Leblond <eric@inl.fr>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756522AbZDNVH5@vger.kernel.org>
In-Reply-To: <1239742000.24204.9.camel@ice-age>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Leblond a =E9crit :
> Hi,
>=20
> Le mardi 14 avril 2009 =E0 22:14 +0200, Eric Dumazet a =E9crit :
>> Mariusz Kozlowski a =E9crit :
>>> On Tue, 14 Apr 2009 14:16:37 +0200
>>> Patrick McHardy <kaber@trash.net> wrote:
>>>
>>>> Eric Dumazet wrote:
>>>>> Patrick McHardy a =E9crit :
>>>>>> Mariusz Kozlowski wrote:
>>>>>>>     netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get ri=
d of
>>>>>>> call_rcu()
>>>>>> Thanks for the report. Does this patch fix it?
>>>>>>
>>>>> Hi Patrick, sorry for the delay, I was in holidays.
>>>> No problem, me too :)
>>>>
> ...
>=20
>> Check commit ca735b3aaa945626ba65a3e51145bfe4ecd9e222
>>
>> netfilter: use a linked list of loggers
>=20
> ...
>=20
>> Signed-off-by: Eric Leblond <eric@inl.fr>
>> Signed-off-by: Patrick McHardy <kaber@trash.net>
>>
>> It seems "struct list_head        list[NFPROTO_NUMPROTO];" is not in=
itialized in "struct nf_logger" ?
>>
>> Please try following patch ?
>=20
> I've just tested your patch. Without it, I was able to trigger the bu=
g
> (modprobe ebt_ulog ; rmmod ebt_ulog). All run cleanly with it.
>=20

OK thanks everybody, I submit it more formally then, using ARRAY_SIZE()=
 macro too :)

[PATCH] netfilter: nf_log fix

commit ca735b3aaa945626ba65a3e51145bfe4ecd9e222
'netfilter: use a linked list of loggers'
introduced an array of list_head in "struct nf_logger", but
forgot to initialize it in nf_log_register(). This resulted
in oops when calling nf_log_unregister() at module unload time.

Reported-and-tested-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Acked-by: Eric Leblond <eric@inl.fr>

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 8bb998f..d8b85ab 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -36,10 +36,14 @@ static struct nf_logger *__find_logger(int pf, cons=
t char *str_logger)
 int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 {
 	const struct nf_logger *llog;
+	int i;
=20
 	if (pf >=3D ARRAY_SIZE(nf_loggers))
 		return -EINVAL;
=20
+	for (i =3D 0; i < ARRAY_SIZE(logger->list); i++)
+		INIT_LIST_HEAD(&logger->list[i]);
+
 	mutex_lock(&nf_log_mutex);
=20
 	if (pf =3D=3D NFPROTO_UNSPEC) {
