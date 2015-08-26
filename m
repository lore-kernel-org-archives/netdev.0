From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: vlan: allow to suppress local
	mac install for all vlans
Date: Wed, 26 Aug 2015 05:56:27 -0700
Message-ID: <A97222E0-27AA-46F1-9354-4A04C0EC1B39@cumulusnetworks.com>
References: <1440464127-27391-1-git-send-email-razor@blackwall.org>
	<55DDB42E.5010802@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com, davem@davemloft.net
To: vyasevic@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <55DDB42E.5010802@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


> On Aug 26, 2015, at 5:42 AM, Vlad Yasevich <vyasevic@redhat.com> =
wrote:
>=20
> On 08/24/2015 08:55 PM, Nikolay Aleksandrov wrote:
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>=20
>> This patch adds a new knob that, when enabled, allows to suppress the
>> installation of local fdb entries in newly created vlans. This could
>> pose a big scalability issue if we have a large number of ports and a
>> large number of vlans, e.g. in a 48 port device with 2000 vlans these
>> entries easily go up to 96000.
>> Note that packets for these macs are still received properly because =
they
>> are added in vlan 0 as "own" macs and referenced when fdb lookup by =
vlan
>> results in a miss.
>> Also note that vlan membership of ingress port and the bridge device
>> as egress are still being correctly enforced.
>>=20
>> The default (0/off) is keeping the current behaviour.
>>=20
>> Based on a patch by Wilson Kok (wkok@cumulusnetworks.com).
>>=20
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>> As usual I'll post iproute2 patch if this one gets accepted.
>>=20
>=20
> ... snip...
>=20
>> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
>> index 3cef6892c0bb..f9efa1b07994 100644
>> --- a/net/bridge/br_vlan.c
>> +++ b/net/bridge/br_vlan.c
>> @@ -98,11 +98,12 @@ static int __vlan_add(struct net_port_vlans *v, =
u16 vid, u16 flags)
>> 			return err;
>> 	}
>>=20
>> -	err =3D br_fdb_insert(br, p, dev->dev_addr, vid);
>> -	if (err) {
>> -		br_err(br, "failed insert local address into bridge "
>> -		       "forwarding table\n");
>> -		goto out_filt;
>> +	if (!br_vlan_ignore_local_fdb(br) || !v->port_idx) {
>> +		err =3D br_fdb_insert(br, p, dev->dev_addr, vid);
>> +		if (err) {
>> +			br_err(br, "failed insert local address into =
bridge forwarding table\n");
>> +			goto out_filt;
>> +		}
>> 	}
>>=20
>=20
> One question.  Does it make sense to push this down into =
br_fdb_insert?
> This patch prevents automatic entries from being added.  But what =
about
> manual entries for a local fdb?  The code in br_fdb_add() will still a
> vid 0 entry as well as entries for all vlans currently configured on =
the port.
>=20
> -vlad
>=20

Good point, it would make sense if we go this way, but as Dave suggested =
it=92d be better
to fix the root cause of the scalability issue rather than trying to =
work around it, so I=92m
dropping this patch for now and will try to come up with a different =
solution, need to look
into this more.

>> 	set_bit(vid, v->vlan_bitmap);
>> @@ -492,6 +493,13 @@ int br_vlan_filter_toggle(struct net_bridge *br, =
unsigned long val)
>> 	return 0;
>> }
>>=20
>> +int br_vlan_ignore_local_fdb_toggle(struct net_bridge *br, unsigned =
long val)
>> +{
>> +	br->vlan_ignore_local_fdb =3D val ? true : false;
>> +
>> +	return 0;
>> +}
>> +
>> int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
>> {
>> 	int err =3D 0;
