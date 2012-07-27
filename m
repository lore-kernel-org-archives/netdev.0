From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [net-next RFC V5 3/5] virtio: intorduce an API to set affinity
	for a virtqueue
Date: Fri, 27 Jul 2012 16:38:11 +0200
Message-ID: <5012A7D3.4040800@redhat.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
	<1341484194-8108-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, mashirle@us.ibm.com,
	kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, sri@us.ibm.com
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1341484194-8108-4-git-send-email-jasowang@redhat.com>
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

Il 05/07/2012 12:29, Jason Wang ha scritto:
> Sometimes, virtio device need to configure irq affiniry hint to maximize the
> performance. Instead of just exposing the irq of a virtqueue, this patch
> introduce an API to set the affinity for a virtqueue.
> 
> The api is best-effort, the affinity hint may not be set as expected due to
> platform support, irq sharing or irq type. Currently, only pci method were
> implemented and we set the affinity according to:
> 
> - if device uses INTX, we just ignore the request
> - if device has per vq vector, we force the affinity hint
> - if the virtqueues share MSI, make the affinity OR over all affinities
>  requested
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Hmm, I don't see any benefit from this patch, I need to use
irq_set_affinity (which however is not exported) to actually bind IRQs
to CPUs.  Example:

with irq_set_affinity_hint:
 43:   89  107  100   97   PCI-MSI-edge   virtio0-request
 44:  178  195  268  199   PCI-MSI-edge   virtio0-request
 45:   97  100   97  155   PCI-MSI-edge   virtio0-request
 46:  234  261  213  218   PCI-MSI-edge   virtio0-request

with irq_set_affinity:
 43:  721    0    0    1   PCI-MSI-edge   virtio0-request
 44:    0  746    0    1   PCI-MSI-edge   virtio0-request
 45:    0    0  658    0   PCI-MSI-edge   virtio0-request
 46:    0    0    1  547   PCI-MSI-edge   virtio0-request

I gathered these quickly after boot, but real benchmarks show the same
behavior, and performance gets actually worse with virtio-scsi
multiqueue+irq_set_affinity_hint than with irq_set_affinity.

I also tried adding IRQ_NO_BALANCING, but the only effect is that I
cannot set the affinity

The queue steering algorithm I use in virtio-scsi is extremely simple
and based on your tx code.  See how my nice pinning is destroyed:

# taskset -c 0 dd if=/dev/sda bs=1M count=1000 of=/dev/null iflag=direct
# cat /proc/interrupts
 43:  2690 2709 2691 2696   PCI-MSI-edge      virtio0-request
 44:   109  122  199  124   PCI-MSI-edge      virtio0-request
 45:   170  183  170  237   PCI-MSI-edge      virtio0-request
 46:   143  166  125  125   PCI-MSI-edge      virtio0-request

All my requests come from CPU#0 and thus go to the first virtqueue, but
the interrupts are serviced all over the place.

Did you set the affinity manually in your experiments, or perhaps there
is a difference between scsi and networking... (interrupt mitigation?)

Paolo
