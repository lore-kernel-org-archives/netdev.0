From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bridge: Add port flap detection
Date: Sun, 4 May 2014 21:06:37 -0700
Message-ID: <CAADnVQL3OZwZ0q_utwE_JhYYGbKPHwwqwHsBZ9g+0XAS__BpWQ@mail.gmail.com>
References: <1399238974-6210-1-git-send-email-jmaxwell@redhat.com>
	<20140504155331.13862a85@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Jon Maxwell <jmaxwell37@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	makita.toshiaki@lab.ntt.co.jp, vyasevic@redhat.com,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	pirko@redhat.com, jmaxwell@redhat.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140504155331.13862a85@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 4, 2014 at 3:53 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Mon,  5 May 2014 07:29:34 +1000
> Jon Maxwell <jmaxwell37@gmail.com> wrote:
>
>> There has been a number incidents recently where customers running KVM have reported that VM hosts on different Hypervisors are unreachable. Based on pcap traces we found that the bridge was broadcasting the ARP request out onto the network. However some NICs have an inbuilt switch which on occasions were broadcasting the VMs ARP request back through the physical NIC on the Hypervisor. This resulted in the bridge flapping ports and incorrectly learning that the VMs mac address was external. As a result the ARP reply was directed back onto the external network and VM never updated it's ARP cache. This patch will detect port flapping and log a message so that this condition can be detected earlier.
>>
>> Signed-off-by: Jon Maxwell <jmaxwell@redhat.com>
>> ---
>>  net/bridge/br_fdb.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
>> index 9203d5a..c08607b 100644
>> --- a/net/bridge/br_fdb.c
>> +++ b/net/bridge/br_fdb.c
>> @@ -507,6 +507,13 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
>>                                       source->dev->name);
>>               } else {
>>                       /* fastpath: update of existing entry */
>> +                     if (source->port_no != fdb->dst->port_no &&
>> +                             net_ratelimit())
>> +                             br_warn(br, "Port flapping detected source entry dev = %s mac = %pM, port_no = %d\n existing entry dev = %s mac = %pM, port_no = %d\n",
>> +                                     source->dev->name,
>> +                                     addr, source->port_no,
>> +                                     fdb->dst->dev->name, addr,
>> +                                     fdb->dst->port_no);
>>                       fdb->dst = source;
>>                       fdb->updated = jiffies;
>>                       if (unlikely(added_by_user))
>
> Ok, but please shorten the message to a single line without excess wordage.
> Plus flapping to mean means link going up and down. Maybe use same message
> as BSD?

Isn't this normal mac move? Any message will be confusing.
VMs can spoof their src macs and trigger this warning.
I don't think it's worth adding it just to debug the learning on the
external interface.
