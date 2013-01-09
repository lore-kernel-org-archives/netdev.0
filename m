From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [PATCH net 1/2] net: dev_queue_xmit_nit: fix
	skb->vlan_tci field value
Date: Wed, 9 Jan 2013 11:27:10 -0800
Message-ID: <CAOxq_8P4PLKXn9FOAWyq4zYH5+Yt7DT1mrU2OSQujGCOjBJZYg@mail.gmail.com>
References: <CAOUgPvRGQ4XQ-HCFzwKi5rFFfC1fJcicH8DxH0pUjAvgxfi7cw@mail.gmail.com>
	<CAOxq_8MXCvGpq4Q0UfxSbWMDNTusrK710fQ11qgfXKWS+zpoZQ@mail.gmail.com>
	<1357712850.27446.28.camel@edumazet-glaptop>
	<CAOxq_8P=yOYGhhJ2_YJT3ya32k7UNjX6d6Qpz+oVfD4d56sJfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman <dborkman@redhat.com>,
	Jiri Pirko <jpirko@redhat.com>, edumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>, tcpdump-workers@lists.tcpdump.org
Return-path: <tcpdump-workers-bounces@lists.tcpdump.org>
In-Reply-To: <CAOxq_8P=yOYGhhJ2_YJT3ya32k7UNjX6d6Qpz+oVfD4d56sJfQ@mail.gmail.com>
List-Unsubscribe: <https://lists.sandelman.ca/mailman/options/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=unsubscribe>
List-Archive: <http://lists.sandelman.ca/pipermail/tcpdump-workers>
List-Post: <mailto:tcpdump-workers@lists.tcpdump.org>
List-Help: <mailto:tcpdump-workers-request@lists.tcpdump.org?subject=help>
List-Subscribe: <https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=subscribe>
Sender: tcpdump-workers-bounces@lists.tcpdump.org
Errors-To: tcpdump-workers-bounces@lists.tcpdump.org
List-Id: netdev.vger.kernel.org

>> Thats irrelevant. This only shows that user land was depending on a
>> prior undocumented behavior.

Why do you say that? The following patch from Pirko ensured that on
both RX and TX regardless whether the driver/hw supported vlan
acceleration, the outermost vlan tags will always be extracted out of
the packet and put in skb aux data :

commit bcc6d47903612c3861201cc3a866fb604f26b8b2
Author: Jiri Pirko <jpirko@redhat.com>
Date:   Thu Apr 7 19:48:33 2011 +0000

    net: vlan: make non-hw-accel rx path similar to hw-accel

Now this meant that the filter code should always look into the aux
data for vlan tagging, not in the packet, regardless of hw
acceleration availability. Your patch
b40863c667c16b7a73d4f034a8eab67029b5b15a broke this symmetric
semantics - now on TX on the network tap, we do not have the vlan tags
in the skb aux data.

In my opinion, for a given kernel, the filter code should either look
into the packet offset or in the packet aux data for vlan tags but not
both. Otherwise the filter code becomes incredibly complex since an
inline vlan tag in the packet changes offsets of all headers coming
afterwords and I don't even know if filter code can be correctly
generated in this case. tcpdump-workers folks are CC's here and they
clearly have more experience with libpcap filter code that I do. Hence
I leave it up to them to provide inputs here.

>> What's wrong instructing libpcap to extend the filter to be able to
>> get the correct result, vlan id being in skb->vlan_id (vlan accel on),
>> or in the packet itself (vlan accel off)
>>
>> This way, you could chose if you want to get only accelerated vlan,
>> or non accelerated vlan, or both. And you need no kernel hacking.

This is wrong. Accelerated or not, the kernel code was organized to
have the tags in the packet aux data. So I think this is how user land
should be coded as well.

ani
_______________________________________________
tcpdump-workers mailing list
tcpdump-workers@lists.tcpdump.org
https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers
