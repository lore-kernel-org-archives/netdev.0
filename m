From: Alexander Drozdov <al.drozdov@gmail.com>
Subject: Re: [PATCH] af_packet: don't pass empty blocks for PACKET_V3
Date: Fri, 06 Feb 2015 09:54:21 +0300
Message-ID: <54D4651D.6060300@gmail.com>
References: <1423115891-3578-1-git-send-email-al.drozdov@gmail.com> <CA+FuTScA_2W+MHsZdYfoOKS==1XyogmyF_d+qUy66A5MdyO-5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Guy Harris <guy@alum.mit.edu>, Dan Collins <dan@dcollins.co.nz>
To: Willem de Bruijn <willemb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+FuTScA_2W+MHsZdYfoOKS==1XyogmyF_d+qUy66A5MdyO-5Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05.02.2015 23:01:38 +0300 Willem de Bruijn wrote:
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
> This change would break existing applications that have come
> to depend on the periodic signal.
>
> I don't disagree with the argument that the data ready signal
> should be sent only when a block is full or a timer expires and
> at least some data is waiting, but that is moot at this point.
I missed something. As pointed by Guy Harris <guy@alum.mit.edu>,
before the previous patch periodic signal was not delivered. The previous patch
(da413eec729dae5dc by Dan Collins <dan@dcollins.co.nz>) is for 3.19 kernel only.
Should we care about existing 3.19-only applications?
>
>> Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
>> ---
>>   net/packet/af_packet.c | 10 +++++++++-
>>   1 file changed, 9 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 9cfe2e1..9a2f70a 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -698,6 +698,10 @@ static void prb_retire_rx_blk_timer_expired(unsigned long data)
>>
>>          if (pkc->last_kactive_blk_num == pkc->kactive_blk_num) {
>>                  if (!frozen) {
>> +                       if (!BLOCK_NUM_PKTS(pbd)) {
>> +                               /* An empty block. Just refresh the timer. */
>> +                               goto refresh_timer;
>> +                       }
>>                          prb_retire_current_block(pkc, po, TP_STATUS_BLK_TMO);
>>                          if (!prb_dispatch_next_block(pkc, po))
>>                                  goto refresh_timer;
>> @@ -798,7 +802,11 @@ static void prb_close_block(struct tpacket_kbdq_core *pkc1,
>>                  h1->ts_last_pkt.ts_sec = last_pkt->tp_sec;
>>                  h1->ts_last_pkt.ts_nsec = last_pkt->tp_nsec;
>>          } else {
>> -               /* Ok, we tmo'd - so get the current time */
>> +               /* Ok, we tmo'd - so get the current time.
>> +                *
>> +                * It shouldn't really happen as we don't close empty
>> +                * blocks. See prb_retire_rx_blk_timer_expired().
>> +                */
>>                  struct timespec ts;
>>                  getnstimeofday(&ts);
>>                  h1->ts_last_pkt.ts_sec = ts.tv_sec;
>> --
>> 1.9.1
>>
