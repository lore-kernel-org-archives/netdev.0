From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next] bridge: Synchronize unicast filtering
	with FDB
Date: Mon, 6 Jun 2016 20:03:49 +0900
Message-ID: <83ef3ee5-024a-d97a-147e-58018426c931@lab.ntt.co.jp>
References: <1464942808-3945-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<F363D072-00A6-447C-9EA8-646362CC9F40@cumulusnetworks.com>
	<C993CB45-67E7-4E80-8029-002E165E3504@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	"David S . Miller" <davem@davemloft.net>, Patrick Schaaf <netdev@bof.de>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <C993CB45-67E7-4E80-8029-002E165E3504@cumulusnetworks.com>
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

On 2016/06/04 2:35, Nikolay Aleksandrov wrote:
...
>>> void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char=
 *newaddr)
>>> @@ -288,6 +296,95 @@ out:
>>> 	spin_unlock_bh(&br->hash_lock);
>>> }
>>>
>>> +void br_fdb_sync_uc(struct net_bridge *br)
>>> +{
>>> +	struct net_bridge_vlan_group *vg;
>>> +	struct netdev_hw_addr *ha;
>>> +	int i;
>>> +
>>> +	spin_lock_bh(&br->hash_lock);
>>> +
>>> +	for (i =3D 0; i < BR_HASH_SIZE; i++) {
>>> +		struct hlist_node *h;
>>> +
>>> +		hlist_for_each(h, &br->hash[i]) {
>>> +			struct net_bridge_fdb_entry *f;
>>> +
>>> +			f =3D hlist_entry(h, struct net_bridge_fdb_entry, hlist);
>>> +			if (!f->dst && f->is_local && !f->added_by_user &&
>>> +			    !ether_addr_equal(f->addr.addr, br->dev->dev_addr)) {
>>> +				/* delete old one */
>>> +				fdb_delete_local(br, NULL, f);
>>> +			}
>>> +		}
>>> +	}
>>> +
>>> +	vg =3D br_vlan_group(br);
>>> +
>>> +	/* insert new address,  may fail if invalid address or dup. */
>>> +	netdev_for_each_uc_addr(ha, br->dev) {
>>> +		struct net_bridge_vlan *v;
>>> +
>>> +		fdb_insert(br, NULL, ha->addr, 0);
>>> +
>>> +		if (!vg || !vg->num_vlans)
>>> +			continue;
>>> +
>>> +		list_for_each_entry(v, &vg->vlan_list, vlist)
>>> +			fdb_insert(br, NULL, ha->addr, v->vid);
>>
>> Since here you=E2=80=99re walking over the bridge=E2=80=99s vlan list,=
 you should test the vlans with br_vlan_should_use()
>> because it can be a global context holder if the vlan was configured o=
nly on ports.

Thank you for your feedback.
will fix in v2.

I actually thought that this is the same logic as
br_fdb_change_mac_address() so assumed it should be all right.
Does br_fdb_change_mac_address() need br_vlan_should_use() as well?

Toshiaki Makita
