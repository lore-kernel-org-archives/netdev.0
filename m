From: Kristian Evensen <kristrev@ifi.uio.no>
Subject: Adding data to SKB - odd checksum errors
Date: Sun, 25 Feb 2007 15:34:46 +0200
Message-ID: <45E19076.1080600@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: linux-net@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am working on an algorithm to add data from the previous skb (on the 
queue) to the front of the current skb. This should be beneficial for a 
certain kind of TCP-traffic, and I am curious as to wether it will work 
or not.

Currently I have implemented a small algorithm to copy the data that 
works most of the time. It is called from write_xmit (right before the 
while-loop) and performs a number of checks (does the skb fit in the 
window, does it have enought space - mostly the same as the 
retrans_try_collapse-function) before it copies the data. I first 
"allocate" new data at the back of the skb using skb_put, and if that is 
succsessfull I copy the new data (using first memmove to move the old 
data and then memcpy), update the seq-number of this skb and calculate a 
new checksum. The algorithm will (currently) not work with non-linear 
skbs. I have pasted the code at the bottom of this mail.

The weird thing about this algorithm is that something will suddenly 
make it go wrong/it makes something else go wrong, and the packets that 
I send have the wrong TCP-checksum. I have looked around the code for 
any counters I might have missed or similar, but I cant find any. If I 
have understod skb's correctly, I shouldn't have to update any counters 
except skb->len (which put does) since I dont expand the SKB I only use 
the space already reserved for it.

Does anyone have any ideas to what might be wrong or can spot any 
errors/misunderstandings in my code?

Thanks,
Kristian

The code:

This goes into write_xmit before the loop:
if(sysctl_tcp_thin_aggressive_bundling && tcp_stream_is_thin(tp)){
    if(skb->prev != (struct sk_buff*) &(sk)->sk_write_queue
        && !(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN)
        && (skb_shinfo(skb)->nr_frags == 0 &&
        skb_shinfo(skb->prev)->nr_frags == 0)){
            tcp_trans_try_collapse2(sk, skb, tcp_current_mss(sk, 0))
        }
}

This is the code that copies the data:
static int tcp_trans_try_collapse2(struct sock *sk, struct sk_buff *skb, 
int mss_now)
{
    struct tcp_sock *tp = tcp_sk(sk);

    /* Make sure that this isnt refereced by somebody else
     */
    if(!skb_cloned(skb)){
        struct sk_buff *prev_skb = skb_copy(skb->prev, GFP_ATOMIC);
        int skb_size = skb->len, prev_skb_size = prev_skb->len;
        u16 flags = TCP_SKB_CB(prev_skb)->flags;

        /* Since this technique currently does not support SACK, I
            * return -1 if the previous has been SACK'd. */
        if(TCP_SKB_CB(prev_skb)->sacked & TCPCB_SACKED_ACKED){
            return -1;
        }

        /* Current skb is out of window. */
        if (after(TCP_SKB_CB(skb)->end_seq, tp->snd_una+tp->snd_wnd)){
            return -1;
        }

        /* Punt if not enough space exists in the first SKB for
         * the data in the second, or the total combined payload
         * would exceed the MSS.
         */
        if ((prev_skb_size > skb_tailroom(skb)) ||
            ((skb_size + prev_skb_size) > mss_now)){
            return -1;
        }

        /*To avoid duplicate copies.*/
        if(TCP_SKB_CB(skb)->seq <= TCP_SKB_CB(prev_skb)->seq)
            return -1;

        /*First, check I have enough room*/
        if(skb_tailroom(skb) < prev_skb->len)
            return -1;

        copy = skb_put(skb, prev_skb->len);

        if(copy){
            memmove(skb->data + prev_skb->len, skb->data, skb->len - 
prev_skb->len);
            memcpy(skb->data, prev_skb->data, prev_skb->len);
            TCP_SKB_CB(skb)->seq = TCP_SKB_CB(prev_skb)->seq;
            skb->csum = csum_partial(skb->data, skb->len, 0);
        }

        __kfree_skb(prev_skb);
    }

    return 1;
}
