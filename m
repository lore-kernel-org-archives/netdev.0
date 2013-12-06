From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH v2] virtio-net: free bufs correctly on invalid packet
	length
Date: Thu, 5 Dec 2013 16:09:22 -0800
Message-ID: <CANJ5vPJgN+kc3STB9XYUxoKygWVWwen2Si6UmDKByz--qzH_Mg@mail.gmail.com>
References: <1386278045-23542-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrey Vagin <avagin@openvz.org>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, Michael Dalton <mwdalton@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1386278045-23542-1-git-send-email-mwdalton@google.com>
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

Hi,

A quick note on this patch: I have confirmed that without this
patch a kernel crash occurs if we force a 'packet too short' error
sufficiently many times. This patch eliminates the kernel crash.

Since this crash would be triggered by a hypervisor bug, I made a
small change not reflected in the above patch to make the crash easier
to reproduce for testing purposes. I treated 1 out of every 128 packets
with len < MERGE_BUFFER_LEN as 'too short'. With this change in
place, just running netperf will cause the sender to crash very quickly
(the receiver will transmit pure data ACKs that meet the drop criteria).

If anyone would like to reproduce the crash using the above setup,
I added an unsigned int num_packets field to struct receive_queue and
changed the if condition for the packet too short check in receive_buf()
from:
        if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
to:
        if (unlikely((len < sizeof(struct virtio_net_hdr) + ETH_HLEN) ||
                     (len < MERGE_BUFFER_LEN &&
                      ((++rq->num_packets & 127) == 0)))) {

Best,

Mike
