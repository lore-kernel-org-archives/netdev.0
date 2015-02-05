From: Guy Harris <guy@alum.mit.edu>
Subject: Re: [PATCH] af_packet: don't pass empty blocks for PACKET_V3
Date: Thu, 5 Feb 2015 13:16:30 -0800
Message-ID: <474D8071-4AEC-48F4-B0DC-02D9091CF3DB@alum.mit.edu>
References: <1423115891-3578-1-git-send-email-al.drozdov@gmail.com> <CA+FuTScA_2W+MHsZdYfoOKS==1XyogmyF_d+qUy66A5MdyO-5Q@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Alexander Drozdov <al.drozdov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+FuTScA_2W+MHsZdYfoOKS==1XyogmyF_d+qUy66A5MdyO-5Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 5, 2015, at 12:01 PM, Willem de Bruijn <willemb@google.com> wrote:

> On Wed, Feb 4, 2015 at 9:58 PM, Alexander Drozdov <al.drozdov@gmail.com> wrote:
>> Don't close an empty block on timeout. Its meaningless to
>> pass it to the user. Moreover, passing empty blocks wastes
>> CPU & buffer space increasing probability of packets
>> dropping on small timeouts.
>> 
>> Side effect of this patch is indefinite user-space wait
>> in poll on idle links. But, I believe its better to set
>> timeout for poll(2) when needed than to get empty blocks
>> every millisecond when not needed.
> 
> This change would break existing applications that have come
> to depend on the periodic signal.
> 
> I don't disagree with the argument that the data ready signal
> should be sent only when a block is full or a timer expires and
> at least some data is waiting, but that is moot at this point.

For what it's worth, the BPF packet capture mechanism (which really needs a new name, to distinguish itself from the BPF packet filter language and its implementation(s), but I digress) has the same issue - when the timer expires, a wakeup is delivered even if there are no packets to read.

*However*, if there are no packets available, the buffers aren't rotated, so the empty buffer is left around to be filled up with packets, rather than being made the hold buffer.

Given that before the previous TPACKET_V3 change, wakeups were delivered when packets arrived rather than when a block was closed, presumably code using TPACKET_V3 was capable of dealing with wakeups being delivered when no new blocks had been made available to userland; could TPACKET_V3 work a bit more like BPF and deliver a wakeup when the timer expires *without* closing the empty block?