From: "Xiaoliang (David) Wei" <weixl@cs.caltech.edu>
Subject: Re: [RFC] TCP burst control
Date: Wed, 28 Jul 2004 02:48:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <013001c47488$12a03500$8900a8c0@weixl>
References: <200407070009.i6709wiA026673@ms-smtp-03-eri0.southeast.rr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <rhee@ncsu.edu>, <lxu2@ncsu.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Injong Rhee" <rhee@eos.ncsu.edu>, "'David S. Miller'" <davem@redhat.com>,
        "'Stephen Hemminger'" <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Injong and other Gurus,

    I support this approach to decouple congestion control and burstiness
control. But I have a question for the patch code.

    My question is about the tcp_cwnd_application_limited() in tcp_input.c
(@@ -3823,8 +3828,13 @@ in the patch).
My understanding is that tcp_cwnd_application_limited() is to reduce the
cwnd, according to RFC 2861, to avoid a large sending rate when the
connection resumes full sending speed. The window reduction here is not to
reduce burstiness, but to reduce the cwnd (since the cwnd is not a good
congestion measure after the idling period). But the patch seems to take
this congestion window reduction as a burstiness reduction mechanism, too. I
guess we don't need to change the window reduction in this function? Please
correct me if I made any mistake. Thanks:)

     I copied the part of patch codes that I'm not sure:
------------------------------------------------------------
@@ -3823,8 +3828,13 @@
  /* Limited by application or receiver window. */
  u32 win_used = max(tp->snd_cwnd_used, 2U);
  if (win_used < tp->snd_cwnd) {
+ u32 limit = (tp->snd_cwnd + win_used) >> 1;
  tp->snd_ssthresh = tcp_current_ssthresh(tp);
- tp->snd_cwnd = (tp->snd_cwnd + win_used) >> 1;
+ if (sysctl_tcp_burst_moderation)
+ tp->snd_cwnd = min(tp->snd_cwnd,
+    max(tp->snd_ssthresh, limit));
+ else
+ tp->snd_cwnd = limit;
  }
  tp->snd_cwnd_used = 0;
  }
------------------------------------------------------------

-David

Xiaoliang (David) Wei             Graduate Student in CS@Caltech
http://www.cs.caltech.edu/~weixl
====================================================
----- Original Message ----- 
From: "Injong Rhee" <rhee@eos.ncsu.edu>
To: "'David S. Miller'" <davem@redhat.com>; "'Stephen Hemminger'"
<shemminger@osdl.org>
Cc: <netdev@oss.sgi.com>; <rhee@ncsu.edu>; <lxu2@ncsu.edu>
Sent: Tuesday, July 06, 2004 5:09 PM
Subject: RE: [RFC] TCP burst control


> Hi David and Stephen,
>
> We tested this rate halving. In fact, rate having in fact degrades the
> performance quite a bit. We can send you more information about it. Our
test
> indicates that this feature introduces many timeouts (because of bursts),
> and also cause unnecessary cwnd backoff to reduce the transmission
> unjustifiably low -- so there are many (I will repeat, many) window and
> transmission oscillations during packet losses. We fix this problem
> completely using our own special burst control. It is very simple and easy
> technique to implement. If you need some data to back up our claims, I
will
> send you more. Once we implemented our burst control, we don't have any
> timeouts and not much fluctuation other than congestion control related.
> Currently with rate having, current Linux tcp stack is full of hacks that
in
> fact, hurt the performance of linux tcp (sorry to say this). Our burst
> control, in fact, simplifies a lot of that and makes sure cwnd to follow
> very closely to whatever congestion control algorithm is intended it to
> behave. The Linux Reno burst control in fact interferes with the original
> congestion control (in fact, it tries to do its own), and its performance
is
> very hard to predict.
>
> Hope this helps.
>
> Injong Rhee, Associate Professor
> North Carolina State University
> Raleigh, NC 27699
> rhee@eos.ncsu.edu, http://www.csc.ncsu.edu/faculty/rhee
>
>
> -----Original Message-----
> From: David S. Miller [mailto:davem@redhat.com]
> Sent: Tuesday, July 06, 2004 7:05 PM
> To: Stephen Hemminger
> Cc: netdev@oss.sgi.com; rhee@ncsu.edu
> Subject: Re: [RFC] TCP burst control
>
> On Tue, 6 Jul 2004 15:58:58 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
>
> > When using advanced congestion control it is possible for TCP to decide
> that
> > it has a large window to fill with data right away. The problem is that
if
> TCP
> > creates long bursts, it becomes unfriendly to other flows and is more
> likely
> > to overrun intermediate queues.
> >
> > This patch limits the amount of data in flight. It came from BICTCP 1.1
> but it
> > has been generalized to all TCP congestion algorithms. It has had some
> testing,
> > but needs to be more widely tested.
>
> Both the New Reno and Westwood+ algorithms implement rate-halving to
> solve this problem.
>
> Why can't BICTCP use that instead of this special burst control hack?
>
>
>
