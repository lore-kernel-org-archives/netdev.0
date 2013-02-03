From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v9 net-next 05/12] bridge: Add the ability to
	configure pvid
Date: Sun, 3 Feb 2013 16:20:24 +0100
Message-ID: <CAHXqBFL3-H_HSwUvXqWEC6vgF5mtaciiwYXPZddrP5F8pPyE7g@mail.gmail.com>
References: <1359748930-31475-1-git-send-email-vyasevic@redhat.com>
	<1359748930-31475-6-git-send-email-vyasevic@redhat.com>
	<CAHXqBFKXEHjghyDe4UQs4inH55UzWcsz+eWAXR4qFiM7+4yVxw@mail.gmail.com>
	<CAHXqBFJ3FutyBGNAXPueWLqJncvzNqd69nTJc0nLgUqzFMTWjw@mail.gmail.com>
	<510C786E.5040406@redhat.com>
	<CAHXqBFKOpQUam4aPB0mqWFRYONsdAHSU-jxKx9AJqabvCwupNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: vyasevic@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAHXqBFKOpQUam4aPB0mqWFRYONsdAHSU-jxKx9AJqabvCwupNA@mail.gmail.com>
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

2013/2/3 Micha=B3 Miros=B3aw <mirqus@gmail.com>:
> 2013/2/2 Vlad Yasevich <vyasevic@redhat.com>:
>> On 02/01/2013 08:15 PM, Micha=B3 Miros=B3aw wrote:
>>> 2013/2/2 Micha=B3 Miros=B3aw <mirqus@gmail.com>:
>>>> 2013/2/1 Vlad Yasevich <vyasevic@redhat.com>:
>>>>> A user may designate a certain vlan as PVID.  This means that
>>>>> any ingress frame that does not contain a vlan tag is assigned to
>>>>> this vlan and any forwarding decisions are made with this vlan in min=
d.
>>>>
>>>> [...]
>>>>>
>>>>>   struct net_port_vlans {
>>>>>          u16                             port_idx;
>>>>> +       u16                             pvid;
>>>>
>>>>
>>>> I'm confused about the implementation. I would expect pvid field in
>>>> net_bridge_port and adding a tag if it isn't there on ingress path.
>>>> The rest would be just like without PVIDs. But here you pvid field to
>>>> net_port_vlans, and don't do anything with it in receive nor transmit
>>>> path. Does it work? What am I missing?
>>> Found the answer in next patch (you should merge #5 and #6).
>> It was split for incremental testing.  #5 added the ability to set and
>> delete it without impacting anything.  #6 added the actual work that pvi=
d
>> does.
>>
>>> Still,
>>> the implementation looks overly complicated. If you force the packet
>>> to canonical form on ingress (keeping outer tag in skb->vlan_tci, and
>>> setting skb->vlan_tci =3D pvid if there is no tag) the code should get
>>> simpler.
>>
>>
>> What if there is no outer tag?  That's what the ingress code is doing.
>> If there is no outer tag, pvid is written to vlan_tci.  If there was
>> outer tag in vlan_tci, it's left alone.  This way at the end of ingress
>> vlan_tci is always set.
>> At egress, we grab that tag and compare it against pvid if any.  If it
>> matches, it's stripped.  If it doesn't, we output with the tag thus
>> adding the header.
>>
>> The only thing I can simplify is grab the tci directly at egress, but
>> that's what the code will do anyway.
>
> ... br_allowed_input(..., struct sk_buff **pskb)
> {
>   *pskb =3D vlan_untag(*pskb);
>   skb =3D *pskb;
>   if (!skb)
>     return 0;
>
>   if (!skb->vlan_tci && (pvid & VLAN_TAG_PRESENT))
>     skb->vlan_tci =3D pvid;
>   return check_vlan_allowed(skb->vlan_tci);
> }

Or maybe some cheating to save unconditional vlan_untag()ging: since
vlan_tci is used only when vlan_tx_tag_present() returns true, we can
cache VID there for the bridge code when VLANs are not HW-accelerated.
I'm not sure of this one as I don't know if the netfilter part keeps
vlan_tci intact (quick grep suggests it does).

... br_allowed_input(..., struct sk_buff **pskb)
{
  skb =3D *pskb;
  if (!vlan_tx_tag_present(skb)) {
    if (!__vlan_get_tag(skb, &skb->vlan_tci))
      skb->vlan_tci &=3D VLAN_VID_MASK;
    else
      skb->vlan_tci =3D 0;
  }
  if (!skb->vlan_tci && pvid & VLAN_TAG_PRESENT)  // FIXME:
802.1p-tagged is put in VLAN 0
    skb->vlan_tci =3D pvid;
  return check_vlan_allowed(skb, skb->vlan_tci & VLAN_VID_MASK);
}

struct sk_buff *br_handle_vlan(..., struct sk_buff *skb)
{
   /* we guaranteed in br_allowed_input() that all packets processed
   /* in bridge code will be like received with NETIF_F_HW_VLAN_RX
    * feature enabled or have VID cached in vlan_tci without
    * VLAN_TAG_PRESENT bit set. */

   if ((skb->vlan_tci & VLAN_VID_MASK) | VLAN_TAG_PRESENT !=3D pvid)
     return skb;

   if (!vlan_tx_tag_present(skb)) {
      skb =3D vlan_untag(skb);
      if (!skb)
        return skb;
   }
   skb->vlan_tci =3D 0;  // FIXME: what about 802.1p?
   return skb;
}

Best Regards,
Micha=B3 Miros=B3aw
