From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH v5] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Fri, 25 Oct 2013 20:20:21 +0200
Message-ID: <526AB665.5020402@xdin.com>
References: <5267F4BD.70409@xdin.com> <1382547142.22433.18.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>,
	=?ISO-8859-1?Q?El=EDas_Molina_Mu=F1oz?= <elias.molina@ehu.es>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:52558 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752770Ab3JYSU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Oct 2013 14:20:26 -0400
In-Reply-To: <1382547142.22433.18.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-23 18:52, Joe Perches wrote:
> On Wed, 2013-10-23 at 18:09 +0200, Arvid Brodin wrote:
>> High-availability Seamless Redundancy ("HSR") provides instant failo=
ver
>> redundancy for Ethernet networks. It requires a special network topo=
logy where
>> all nodes are connected in a ring (each node having two physical net=
work
>> interfaces). It is suited for applications that demand high availabi=
lity and
>> very short reaction time.
>=20
> trivia: (can be ignored/fixed later)
>=20
>> +static void restore_slaves(struct net_device *hsr_dev)
>> +{
>> +	struct hsr_priv *hsr_priv;
>> +	int i;
>> +	int res;
>> +
>> +	hsr_priv =3D netdev_priv(hsr_dev);
>> +
>> +	rtnl_lock();
>> +
>> +	/* Restore promiscuity */
>> +	for (i =3D 0; i < 2; i++) {
>=20
> I presume all of these for slave loops that use
> for (i =3D 0; i < 2; i++) should be i < HSR_MAX_SLAVE

Yes, that's not nice at all. Will fix.
=20
> Maybe it'd be useful to add a foreach_slave() helper.

I experimented a bit with this, but since the slaves are held in an arr=
ay and
can be NULL, and since we aren't allowed to do for loop initial declara=
tions,
it became a bit cumbersome. So I'll stick with the "manual" for loops.

=20
>> +static struct node_entry *find_node_by_AddrA(struct list_head *node=
_db,
>> +					     const unsigned char addr[ETH_ALEN])
>> +{
>> +	struct node_entry *node;
>> +
>> +	list_for_each_entry_rcu(node, node_db, mac_list) {
>> +		if (!compare_ether_addr(node->MacAddressA, addr))
>=20
> Please use ether_addr_equal instead for all these uses.
> compare_ether_addr should be removed one day.

Ok! Much nicer with ether_addr_equal().


>> +static struct node_entry *find_node_by_AddrB(struct list_head *node=
_db,
>> +					     const unsigned char addr[ETH_ALEN])
> []
>> +		if (!compare_ether_addr(node->MacAddressB, addr))
> []
>> +struct node_entry *hsr_find_node(struct list_head *node_db, struct =
sk_buff *skb)
> []
>> +		if (!compare_ether_addr(node->MacAddressA, ethhdr->h_source))
>> +			return node;
>> +		if (!compare_ether_addr(node->MacAddressB, ethhdr->h_source))
>> +			return node;
>=20
>> +struct node_entry *hsr_merge_node(struct hsr_priv *hsr_priv,
>> +				  struct node_entry *node,
>> +				  struct sk_buff *skb,
>> +				  enum hsr_dev_idx dev_idx)
> []
>> +	if (node && compare_ether_addr(node->MacAddressA, hsr_sp->MacAddre=
ssA)) {
> []
>> +	if (node && (dev_idx =3D=3D node->AddrB_if) &&
>> +	    compare_ether_addr(node->MacAddressB, hsr_ethsup->ethhdr.h_sou=
rce)) {
> []
>> +	if (node && (dev_idx !=3D node->AddrB_if) &&
>> +	    (node->AddrB_if !=3D HSR_DEV_NONE) &&
>> +	    compare_ether_addr(node->MacAddressA, hsr_ethsup->ethhdr.h_sou=
rce)) {
> []
>> +	if (compare_ether_addr(hsr_sp->MacAddressA, hsr_ethsup->ethhdr.h_s=
ource))
>=20
> []
>=20
>> +/* above(a, b) - return 1 if a > b, 0 otherwise.
>> + */
>> +static bool above(u16 a, u16 b)
>> +{
>> +	/* Remove inconsistency where above(a, b) =3D=3D below(a, b) */
>> +	if ((int) b - a =3D=3D 32768)
>> +		return 0;
>> +
>> +	return (((s16) (b - a)) < 0);
>> +}
>> +#define below(a, b)		above((b), (a))
>> +#define above_or_eq(a, b)	(!below((a), (b)))
>> +#define below_or_eq(a, b)	(!above((a), (b)))
>=20
> This looks odd.=20

It relies on unsigned arithmetic to compare two values that may wrap. I=
=2Ee.,
it doesn't care about the absolute sizes, but only about the distance=20
between the numbers.=20

It is inspired in part by the code in jiffies.h, but adapted to 16-bit
types. The code you suggested (below) will not work in this case.

See e.g. http://en.wikipedia.org/wiki/Serial_number_arithmetic


>=20
> static bool above(u16 a, u16 b)
> {
> 	return a > b;
> }
> #define below(a, b) above(b, a)
>=20
> static bool above_or_eq(u16 a, u16 b)
> {
> 	return a >=3D b;
> }
> #define below_or_eq(a, b) above_or_eq(b, a)
>=20
>=20
>=20


--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
