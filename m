From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] vhost_net: stop polling socket during rx processing
Date: Tue, 3 May 2016 10:52:44 +0800
Message-ID: <5728127C.6040101@redhat.com>
References: <1461656153-24074-1-git-send-email-jasowang@redhat.com>
	<20160427141317-mutt-send-email-mst@redhat.com>
	<5721AB7B.8070806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <5721AB7B.8070806@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On 04/28/2016 02:19 PM, Jason Wang wrote:
> On 04/27/2016 07:28 PM, Michael S. Tsirkin wrote:
>> > On Tue, Apr 26, 2016 at 03:35:53AM -0400, Jason Wang wrote:
>>> >> We don't stop polling socket during rx processing, this will lead
>>> >> unnecessary wakeups from under layer net devices (E.g
>>> >> sock_def_readable() form tun). Rx will be slowed down in this
>>> >> way. This patch avoids this by stop polling socket during rx
>>> >> processing. A small drawback is that this introduces some overheads in
>>> >> light load case because of the extra start/stop polling, but single
>>> >> netperf TCP_RR does not notice any change. In a super heavy load case,
>>> >> e.g using pktgen to inject packet to guest, we get about ~17%
>>> >> improvement on pps:
>>> >>
>>> >> before: ~1370000 pkt/s
>>> >> after:  ~1500000 pkt/s
>>> >>
>>> >> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> > Acked-by: Michael S. Tsirkin <mst@redhat.com>
>> >
>> > There is one other possible enhancement: we actually have the wait queue
>> > lock taken in _wake_up, but we give it up only to take it again in the
>> > handler.
>> >
>> > It would be nicer to just remove the entry when we wake
>> > the vhost thread. Re-add it if required.
>> > I think that something like the below would give you the necessary API.
>> > Pls feel free to use it if you are going to implement a patch on top
>> > doing this - that's not a reason not to include this simple patch
>> > though.
> Thanks, this looks useful, will give it a try.

Want to try, but looks like this will result a strange API:

- poll were removed automatically during wakeup, handler does not need
to care about this
- but handler still need to re-add the poll explicitly in the code

?
