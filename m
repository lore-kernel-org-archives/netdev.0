From: =?utf-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH v2] geneve: Fix setting ttl value in collect metadata mode
Date: Wed, 13 Sep 2017 19:15:31 +0800
Message-ID: <95A24784-0575-47CE-A485-B2A59911262A@cmss.chinamobile.com>
References: <1505199911-21153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <CAOrHB_AWuWXw1fLvY2arKf0XO6GM0g379KDadwf=ymz47cTOMw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        Girish Moodalbail <girish.moodalbail@oracle.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOrHB_AWuWXw1fLvY2arKf0XO6GM0g379KDadwf=ymz47cTOMw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 2017年9月13日, at 上午7:43, Pravin Shelar <pshelar@ovn.org> wrote:
> 
> On Tue, Sep 12, 2017 at 12:05 AM, Haishuang Yan
> <yanhaishuang@cmss.chinamobile.com> wrote:
>> Similar to vxlan/ipip tunnel, if key->tos is zero in collect metadata
>> mode, tos should also fallback to ip{4,6}_dst_hoplimit.
>> 
>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>> 
>> ---
>> Changes since v2:
>>  * Make the commit message more clearer.
>> ---
>> drivers/net/geneve.c | 6 ++----
>> 1 file changed, 2 insertions(+), 4 deletions(-)
>> 
>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>> index f640407..d52a65f 100644
>> --- a/drivers/net/geneve.c
>> +++ b/drivers/net/geneve.c
>> @@ -834,11 +834,10 @@ static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
>>        sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
>>        if (geneve->collect_md) {
>>                tos = ip_tunnel_ecn_encap(key->tos, ip_hdr(skb), skb);
>> -               ttl = key->ttl;
>>        } else {
>>                tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, ip_hdr(skb), skb);
>> -               ttl = key->ttl ? : ip4_dst_hoplimit(&rt->dst);
>>        }
>> +       ttl = key->ttl ? : ip4_dst_hoplimit(&rt->dst);
>>        df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
>> 
> This changes user API of Geneve collect-metadata mode. I do not see
> good reason for this. Why user can not set right TTL for the flow?
> 

For example, I test this case with script samples/bpf/test_tunnel_bpf.sh, 
and modify samples/bpf/tcbpf2_kern.c with following patch:

diff --git a/samples/bpf/tcbpf2_kern.c b/samples/bpf/tcbpf2_kern.c
index 370b749..16b09ed 100644
--- a/samples/bpf/tcbpf2_kern.c
+++ b/samples/bpf/tcbpf2_kern.c
@@ -204,7 +204,6 @@ int _geneve_set_tunnel(struct __sk_buff *skb)
        key.remote_ipv4 = 0xac100164; /* 172.16.1.100 */
        key.tunnel_id = 2;
        key.tunnel_tos = 0;
-       key.tunnel_ttl = 64;

        __builtin_memset(&gopt, 0x0, sizeof(gopt));
        gopt.opt_class = 0x102; /* Open Virtual Networking (OVN) */

The user didn’t set key.tunnel_ttl and then key.tunnel_ttl is 0, so tcpdump 
output on veth1 would have ttl value of 0 in ip header:

PING 10.1.1.100 (10.1.1.100) 56(84) bytes of data.
18:59:27.347373 82:81:85:8a:72:62 > 7e:99:fb:3b:15:73, ethertype IPv4 (0x0800), length 104: (tos 0x0, id 7386, offset 0, flags [none], proto UDP
(17), length 90)
64 bytes from 10.1.1.100: icmp_seq=1 ttl=64 time=0.083 ms
    172.16.1.200.57776 > 172.16.1.100.6081: [no cksum] UDP, length 62

--- 10.1.1.100 ping statistics —

After my patch, tcpdump output on veth1 would have ttl value of 64 in 
ip header:

PING 10.1.1.100 (10.1.1.100) 56(84) bytes of data.
19:12:10.870410 f2:56:13:68:e9:a9 > 8a:1e:93:dc:59:27, ethertype IPv4 (0x0800), length 104: (tos 0x0, ttl 64, id 48595, offset 0, flags [none], p
roto UDP (17), length 90)
64 bytes from 10.1.1.100: icmp_seq=1 ttl=64 time=0.091 ms
    172.16.1.200.57776 > 172.16.1.100.6081: [no cksum] UDP, length 62

--- 10.1.1.100 ping statistics ---
