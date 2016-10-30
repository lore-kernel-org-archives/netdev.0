From: Jonathan Maxwell <jmaxwell37@gmail.com>
Subject: Re: [PATCH net-next] ibmveth: v1 calculate correct gso_size and set gso_type
Date: Sun, 30 Oct 2016 11:21:56 +1100
Message-ID: <CAGHK07DdHJKW_YPrTb1r0u2k9SXD2MCZ3Gw_qQTdv-qQdSZN2A@mail.gmail.com>
References: <1477440555-21133-1-git-send-email-jmaxwell37@gmail.com>
 <1477582016.7065.212.camel@edumazet-glaptop3.roam.corp.google.com>
 <7b97bb2a-63ed-7dde-9a2f-e390c67de382@linux.vnet.ibm.com> <1477591717.7065.237.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Jon Maxwell <jmaxwell@redhat.com>, hofrat@osadl.org,
        linux-kernel@vger.kernel.org, jarod@redhat.com,
        netdev@vger.kernel.org, paulus@samba.org,
        Tom Herbert <tom@herbertland.com>,
        Marcelo Ricardo Leitner <mleitner@redhat.com>,
        linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32794 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752437AbcJ3AV5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 20:21:57 -0400
In-Reply-To: <1477591717.7065.237.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 28, 2016 at 5:08 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-10-27 at 12:54 -0500, Thomas Falcon wrote:
>> On 10/27/2016 10:26 AM, Eric Dumazet wrote:
>> > On Wed, 2016-10-26 at 11:09 +1100, Jon Maxwell wrote:
>> >> We recently encountered a bug where a few customers using ibmveth on the
>> >> same LPAR hit an issue where a TCP session hung when large receive was
>> >> enabled. Closer analysis revealed that the session was stuck because the
>> >> one side was advertising a zero window repeatedly.
>> >>
>> >> We narrowed this down to the fact the ibmveth driver did not set gso_size
>> >> which is translated by TCP into the MSS later up the stack. The MSS is
>> >> used to calculate the TCP window size and as that was abnormally large,
>> >> it was calculating a zero window, even although the sockets receive buffer
>> >> was completely empty.
>> >>
>> >> We were able to reproduce this and worked with IBM to fix this. Thanks Tom
>> >> and Marcelo for all your help and review on this.
>> >>
>> >> The patch fixes both our internal reproduction tests and our customers tests.
>> >>
>> >> Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
>> >> ---
>> >>  drivers/net/ethernet/ibm/ibmveth.c | 20 ++++++++++++++++++++
>> >>  1 file changed, 20 insertions(+)
>> >>
>> >> diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
>> >> index 29c05d0..c51717e 100644
>> >> --- a/drivers/net/ethernet/ibm/ibmveth.c
>> >> +++ b/drivers/net/ethernet/ibm/ibmveth.c
>> >> @@ -1182,6 +1182,8 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
>> >>    int frames_processed = 0;
>> >>    unsigned long lpar_rc;
>> >>    struct iphdr *iph;
>> >> +  bool large_packet = 0;
>> >> +  u16 hdr_len = ETH_HLEN + sizeof(struct tcphdr);
>> >>
>> >>  restart_poll:
>> >>    while (frames_processed < budget) {
>> >> @@ -1236,10 +1238,28 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
>> >>                                            iph->check = 0;
>> >>                                            iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
>> >>                                            adapter->rx_large_packets++;
>> >> +                                          large_packet = 1;
>> >>                                    }
>> >>                            }
>> >>                    }
>> >>
>> >> +                  if (skb->len > netdev->mtu) {
>> >> +                          iph = (struct iphdr *)skb->data;
>> >> +                          if (be16_to_cpu(skb->protocol) == ETH_P_IP &&
>> >> +                              iph->protocol == IPPROTO_TCP) {
>> >> +                                  hdr_len += sizeof(struct iphdr);
>> >> +                                  skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
>> >> +                                  skb_shinfo(skb)->gso_size = netdev->mtu - hdr_len;
>> >> +                          } else if (be16_to_cpu(skb->protocol) == ETH_P_IPV6 &&
>> >> +                                     iph->protocol == IPPROTO_TCP) {
>> >> +                                  hdr_len += sizeof(struct ipv6hdr);
>> >> +                                  skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
>> >> +                                  skb_shinfo(skb)->gso_size = netdev->mtu - hdr_len;
>> >> +                          }
>> >> +                          if (!large_packet)
>> >> +                                  adapter->rx_large_packets++;
>> >> +                  }
>> >> +
>> >>
>> > This might break forwarding and PMTU discovery.
>> >
>> > You force gso_size to device mtu, regardless of real MSS used by the TCP
>> > sender.
>> >
>> > Don't you have the MSS provided in RX descriptor, instead of guessing
>> > the value ?
>> >
>> >
>> >
>> The MSS is not always available unfortunately, so this is the best solution there is at the moment.
>
> Hmm... then what about skb_shinfo(skb)->gso_segs ?
>
> ip_rcv() for example has :
>
>         __IP_ADD_STATS(net,
>                        IPSTATS_MIB_NOECTPKTS + (iph->tos & INET_ECN_MASK),
>                        max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));
>
>

Okay thanks Eric. As the MSS is the main concern, let me work with the
team here and see if we find can a better way to do this. Will take care of
the other points you raised at the same time.

>
> Also prefer : (skb->protocol == htons(ETH_P_IP)) tests
>
> And the ipv6 test is wrong :
>
> } else if (be16_to_cpu(skb->protocol) == ETH_P_IPV6 &&
>            iph->protocol == IPPROTO_TCP) {
>
>
> Since iph is a pointer to ipv4 iphdr .
>
>
>
