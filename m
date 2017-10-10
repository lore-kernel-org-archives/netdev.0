From: "Jacob, Christina" <Christina.Jacob@cavium.com>
Subject: Re: [PATCH 1/1] xdp: Sample xdp program implementing ip forward
Date: Tue, 10 Oct 2017 02:24:39 +0000
Message-ID: <DM5PR07MB346820D37943C5C343C3AE588A750@DM5PR07MB3468.namprd07.prod.outlook.com>
References: <1507016225-319-1-git-send-email-Christina.Jacob@cavium.com>
 <1507016225-319-2-git-send-email-Christina.Jacob@cavium.com>,<59D3B2A2.4030100@iogearbox.net>,<DM5PR07MB346826EDCF6C5F2B1287D1578A710@DM5PR07MB3468.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DM5PR07MB346826EDCF6C5F2B1287D1578A710@DM5PR07MB3468.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for the late reply. I will include the suggested changes in the next =
revision of the patch.

Please see inline for clarifications and questions.


Thanks,

Christina


________________________________
From: Daniel Borkmann <daniel@iogearbox.net>
Sent: Tuesday, October 3, 2017 9:24 PM
To: Jacob, Christina; netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org; linux-arm-kernel@lists.infradead.org; ale=
xei.starovoitov@gmail.com
Subject: Re: [PATCH 1/1] xdp: Sample xdp program implementing ip forward

>On 10/03/2017 09:37 AM, cjacob wrote:
>> Implements port to port forwarding with route table and arp table
>> lookup for ipv4 packets using bpf_redirect helper function and
>> lpm_trie  map.
>>
>> Signed-off-by: cjacob <Christina.Jacob@cavium.com>
>
>Thanks for the patch, just few minor comments below!
>
>Note, should be full name, e.g.:
>
>   Signed-off-by: Christina Jacob <Christina.Jacob@cavium.com>
>
>Also you From: only shows 'cjacob' as can be seen from the cover letter
>as well, so perhaps check your git settings to make that full name:
>
>   cjacob (1):
>     xdp: Sample xdp program implementing ip forward
>
>If there's one single patch, then cover letter is not needed, only
>for >1 sets.
>
>[...]
>> +#define KBUILD_MODNAME "foo"
>> +#include <uapi/linux/bpf.h>
>> +#include <linux/in.h>
>> +#include <linux/if_ether.h>
>> +#include <linux/if_packet.h>
>> +#include <linux/if_vlan.h>
>> +#include <linux/ip.h>
>> +#include <linux/ipv6.h>
>> +#include "bpf_helpers.h"
>> +#include <linux/slab.h>
>> +#include <net/ip_fib.h>
>> +
>> +struct trie_value {
>> +     __u8 prefix[4];
>> +     long value;
>> +     int gw;
>> +     int ifindex;
>> +     int metric;
>> +};
>> +
>> +union key_4 {
>> +     u32 b32[2];
>> +     u8 b8[8];
>> +};
>> +
>> +struct arp_entry {
>> +     int dst;
>> +     long mac;
>> +};
>> +
>> +struct direct_map {
>> +     long mac;
>> +     int ifindex;
>> +     struct arp_entry arp;
>> +};
>> +
>> +/* Map for trie implementation*/
>> +struct bpf_map_def SEC("maps") lpm_map =3D {
>> +     .type =3D BPF_MAP_TYPE_LPM_TRIE,
>> +     .key_size =3D 8,
>> +     .value_size =3D
>> +             sizeof(struct trie_value),
>
>(Nit: there are couple of such breaks throughout the patch, can we
>  just use single line for such cases where reasonable?)
>
>> +     .max_entries =3D 50,
>> +     .map_flags =3D BPF_F_NO_PREALLOC,
>> +};
>> +
>> +/* Map for counter*/
>> +struct bpf_map_def SEC("maps") rxcnt =3D {
>> +     .type =3D BPF_MAP_TYPE_PERCPU_ARRAY,
>> +     .key_size =3D sizeof(u32),
>> +     .value_size =3D sizeof(long),
>> +     .max_entries =3D 256,
>> +};
>> +
>> +/* Map for ARP table*/
>> +struct bpf_map_def SEC("maps") arp_table =3D {
>> +     .type =3D BPF_MAP_TYPE_HASH,
>> +     .key_size =3D sizeof(int),
>> +     .value_size =3D sizeof(long),
>
>Perhaps these should be proper structs here, such that it
>becomes easier to read/handle later on lookup.
>

I am not clear about this. I am defining a ebpf map.
I did not understand what structure you are refering to
Am I missing something here?.

>> +     .max_entries =3D 50,
>> +};
>> +
>> +/* Map to keep the exact match entries in the route table*/
>> +struct bpf_map_def SEC("maps") exact_match =3D {
>> +     .type =3D BPF_MAP_TYPE_HASH,
>> +     .key_size =3D sizeof(int),
>> +     .value_size =3D sizeof(struct direct_map),
>> +     .max_entries =3D 50,
>> +};
>> +
>> +/**
>> + * Function to set source and destination mac of the packet
>> + */
>> +static inline void set_src_dst_mac(void *data, void *src, void *dst)
>> +{
>> +     unsigned short *p      =3D data;
>> +     unsigned short *dest   =3D dst;
>> +     unsigned short *source =3D src;
>> +
>> +     p[3] =3D source[0];
>> +     p[4] =3D source[1];
>> +     p[5] =3D source[2];
>> +     p[0] =3D dest[0];
>> +     p[1] =3D dest[1];
>> +     p[2] =3D dest[2];
>
>You could just use __builtin_memcpy() given length is
>constant anyway, so LLVM will do the inlining.
>
>> +}
>> +
>> +/**
>> + * Parse IPV4 packet to get SRC, DST IP and protocol
>> + */
>> +static inline int parse_ipv4(void *data, u64 nh_off, void *data_end,
>> +                          unsigned int *src, unsigned int *dest)
>> +{
>> +     struct iphdr *iph =3D data + nh_off;
>> +
>> +     if (iph + 1 > data_end)
>> +             return 0;
>> +     *src =3D (unsigned int)iph->saddr;
>> +     *dest =3D (unsigned int)iph->daddr;
>
>Why not stay with __be32 types?
>
>> +     return iph->protocol;
>> +}
>> +
>> +SEC("xdp3")
>> +int xdp_prog3(struct xdp_md *ctx)
>> +{
>> +     void *data_end =3D (void *)(long)ctx->data_end;
>> +     void *data =3D (void *)(long)ctx->data;
>> +     struct ethhdr *eth =3D data;
>> +     int rc =3D XDP_DROP, forward_to;
>> +     long *value;
>> +     struct trie_value *prefix_value;
>> +     long *dest_mac =3D NULL, *src_mac =3D NULL;
>> +     u16 h_proto;
>> +     u64 nh_off;
>> +     u32 ipproto;
>> +     union key_4 key4;
>> +
>> +     nh_off =3D sizeof(*eth);
>> +     if (data + nh_off > data_end)
>> +             return rc;
>> +
>> +     h_proto =3D eth->h_proto;
>> +
>> +     if (h_proto =3D=3D htons(ETH_P_8021Q) || h_proto =3D=3D htons(ETH_=
P_8021AD)) {
>> +             struct vlan_hdr *vhdr;
>> +
>> +             vhdr =3D data + nh_off;
>> +             nh_off +=3D sizeof(struct vlan_hdr);
>> +             if (data + nh_off > data_end)
>> +                     return rc;
>> +             h_proto =3D vhdr->h_vlan_encapsulated_proto;
>> +     }
>> +     if (h_proto =3D=3D htons(ETH_P_ARP)) {
>> +             return XDP_PASS;
>> +     } else if (h_proto =3D=3D htons(ETH_P_IP)) {
>> +             int src_ip =3D 0, dest_ip =3D 0;
>> +             struct direct_map *direct_entry;
>> +
>> +             ipproto =3D parse_ipv4(data, nh_off, data_end, &src_ip, &d=
est_ip);
>> +             direct_entry =3D (struct direct_map *)bpf_map_lookup_elem
>> +                     (&exact_match, &dest_ip);
>> +             /*check for exact match, this would give a faster lookup*/
>> +             if (direct_entry && direct_entry->mac &&
>> +                 direct_entry->arp.mac) {
>> +                     src_mac =3D &direct_entry->mac;
>> +                     dest_mac =3D &direct_entry->arp.mac;
>> +                     forward_to =3D direct_entry->ifindex;
>> +             } else {
>> +                     /*Look up in the trie for lpm*/
>> +                     // Key for trie
>
>Nit: please check style throughout the patch.
>
>> +                     key4.b32[0] =3D 32;
>> +                     key4.b8[4] =3D dest_ip % 0x100;
>> +                     key4.b8[5] =3D (dest_ip >> 8) % 0x100;
>> +                     key4.b8[6] =3D (dest_ip >> 16) % 0x100;
>> +                     key4.b8[7] =3D (dest_ip >> 24) % 0x100;
>> +                     prefix_value =3D
>> +                             ((struct trie_value *)bpf_map_lookup_elem
>> +                              (&lpm_map, &key4));
>
>For key, please use proper struct bpf_lpm_trie_key, see also
>usage example in tools/testing/selftests/bpf/test_lpm_map.c
>for LPM handling.
>

I am following the way how it is done in the kernel program of other sample=
 programs.
Can we do dynamic memory allocation in ebpf kernel program. I am getting in=
valid instruction errors in runtime.

>> +                     if (!prefix_value) {
>> +                             return XDP_DROP;
>> +                     } else {
>> +                             src_mac =3D &prefix_value->value;
>> +                             if (src_mac) {
>> +                                     dest_mac =3D (long *)bpf_map_looku=
p_elem
>> +                                             (&arp_table, &dest_ip);
>> +                                     if (!dest_mac) {
>> +                                             if (prefix_value->gw) {
>> +                                                     dest_ip =3D *(unsi=
gned int *)(&(prefix_value->gw));
>> +                                                     dest_mac =3D (long=
 *)bpf_map_lookup_elem
>> +                                                             (&arp_tabl=
e, &dest_ip);
>> +                                             } else {
>> +                                                     return XDP_DROP;
>> +                                             }
>> +                                     }
>> +                                     forward_to =3D prefix_value->ifind=
ex;
>> +                             } else {
>> +                                     return XDP_DROP;
>> +                             }
>> +                     }
>> +             }
>> +     } else {
>> +             ipproto =3D 0;
>> +     }
>> +     if (src_mac && dest_mac) {
>> +             set_src_dst_mac(data, src_mac,
>> +                             dest_mac);
>> +             value =3D bpf_map_lookup_elem
>> +                     (&rxcnt, &ipproto);
>> +             if (value)
>> +                     *value +=3D 1;
>> +             return  bpf_redirect(
>> +                                  forward_to,
>> +                                  0);
>> +     }
>> +     return rc;
