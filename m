From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] Revert "net: sctp: Fix a_rwnd/rwnd management to
 reflect real state of the receiver's buffer"
Date: Wed, 16 Apr 2014 14:50:37 -0400
Message-ID: <534ED0FD.4040709@gmail.com>
References: <1397504717-19566-1-git-send-email-dborkman@redhat.com> <534C3DC2.9070604@gmail.com> <534E29D4.60100@nsn.com> <CAE8XmWqgcNAHcKnzdUamQ0T+NP27GKSiRv37JEHSQW-=1Fu=2w@mail.gmail.com> <534E473E.20303@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: Alexander Sverdlin <alexander.sverdlin@nsn.com>,
	ext Dongsheng Song <dongsheng.song@gmail.com>,
	Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:38031 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754600AbaDPSun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 14:50:43 -0400
In-Reply-To: <534E473E.20303@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2014 05:02 AM, Alexander Sverdlin wrote:
> Hi Dongsheng!
>
> On 16/04/14 10:39, ext Dongsheng Song wrote:
>> >From my testing, netperf throughput from 600 Mbit/s drop to 6 Mbit/s,
>> the penalty is 99 %.
>
> The question was, do you see this as a problem of the new rwnd algorithm?
> If yes, how exactly?

The algorithm isn't wrong, but the implementation appears to have
a bug with window update SACKs.  The problem is that
sk->sk_rmem_alloc is updated by the skb destructor when
skb is freed.  This happens after we call sctp_assoc_rwnd_update()
which tries to send the update SACK.  As a result, in default
config with per-socket accounting, the test
    if ((asoc->base.sk->sk_rcvbuf - rx_count) > 0)
uses the wrong values for rx_count and results in advertisement
of decreased rwnd instead of what is really available.

Can you try this patch without the revert applied.

Thanks
-vlad

diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 8d198ae..cc2d440 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -1011,7 +1011,6 @@ static void sctp_ulpevent_release_data(struct
sctp_ulpevent *event)
 {
 	struct sk_buff *skb, *frag;
 	unsigned int	len;
-	struct sctp_association *asoc;

 	/* Current stack structures assume that the rcv buffer is
 	 * per socket.   For UDP style sockets this is not true as
@@ -1036,11 +1035,7 @@ static void sctp_ulpevent_release_data(struct
sctp_ulpevent *event)
 	}

 done:
-	asoc = event->asoc;
-	sctp_association_hold(asoc);
 	sctp_ulpevent_release_owner(event);
-	sctp_assoc_rwnd_update(asoc, true);
-	sctp_association_put(asoc);
 }

 static void sctp_ulpevent_release_frag_data(struct sctp_ulpevent *event)
@@ -1071,12 +1066,21 @@ done:
  */
 void sctp_ulpevent_free(struct sctp_ulpevent *event)
 {
+	struct sctp_association *assoc = event->asoc;
+
 	if (sctp_ulpevent_is_notification(event))
 		sctp_ulpevent_release_owner(event);
 	else
 		sctp_ulpevent_release_data(event);

 	kfree_skb(sctp_event2skb(event));
+	/* The socket is locked and the assocaiton can't go anywhere
+	 * since we are walking the uplqueue.  No need to hold
+	 * another ref on the association.  Now that the skb has been
+	 * freed and accounted for everywhere, see if we need to send
+	 * a window update SACK.
+	 */
+	sctp_assoc_rwnd_update(asoc, true);
 }

 /* Purge the skb lists holding ulpevents. */


> The algorithm actually has no preference to any amount of data.
> It was fine-tuned before to serve as congestion control algorithm, but
this should
> be located elsewhere. Perhaps, indeed, a re-use of congestion control
modules from
> TCP would be possible...
>
>> http://www.spinics.net/lists/linux-sctp/msg03308.html
>>
>>
>> On Wed, Apr 16, 2014 at 2:57 PM, Matija Glavinic Pecotic
>> <matija.glavinic-pecotic.ext@nsn.com> wrote:
>>>
>>> Hello Vlad,
>>>
>>> On 04/14/2014 09:57 PM, ext Vlad Yasevich wrote:
>>>> The base approach is sound.  The idea is to calculate rwnd based
>>>> on receiver buffer available.  The algorithm chosen however, is
>>>> gives a much higher preference to small data and penalizes large
>>>> data transfers.  We need to figure our something else here..
>>>
>>> I don't follow you here. Could you please explain what do you see as
penalty?
>>>
>>> Thanks,
>>>
>>> Matija
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>
