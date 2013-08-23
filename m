From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 2/6] vhost_net: use vhost_add_used_and_signal_n() in
	vhost_zerocopy_signal_used()
Date: Fri, 23 Aug 2013 16:50:38 +0800
Message-ID: <5217225E.2060006@redhat.com>
References: <1376630190-5912-1-git-send-email-jasowang@redhat.com>
	<1376630190-5912-3-git-send-email-jasowang@redhat.com>
	<20130816095426.GA21821@redhat.com> <5212D564.80200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <5212D564.80200@redhat.com>
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

On 08/20/2013 10:33 AM, Jason Wang wrote:
> On 08/16/2013 05:54 PM, Michael S. Tsirkin wrote:
>> On Fri, Aug 16, 2013 at 01:16:26PM +0800, Jason Wang wrote:
>>>> Switch to use vhost_add_used_and_signal_n() to avoid multiple calls to
>>>> vhost_add_used_and_signal(). With the patch we will call at most 2 times
>>>> (consider done_idx warp around) compared to N times w/o this patch.
>>>>
>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> So? Does this help performance then?
>>
> Looks like it can especially when guest does support event index. When
> guest enable tx interrupt, this can saves us some unnecessary signal to
> guest. I will do some test.

Have done some test. I can see 2% - 3% increasing in both aggregate
transaction rate and per cpu transaction rate in TCP_RR and UDP_RR test.

I'm using ixgbe. W/o this patch, I can see more than 100 calls of
vhost_add_used_signal() in one vhost_zerocopy_signaled_used(). This is
because ixgbe (and other modern ethernet driver) tends to free old tx
skbs in a loop during tx interrupt, and vhost tend to batch the adding
used and signal in vhost_zerocopy_callback(). Switching to use
vhost_add_use_and_signal_n() means saving 100 times of used idx updating
and memory barriers.
