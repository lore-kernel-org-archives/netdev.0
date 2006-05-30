From: "Xiaoliang (David) Wei" <davidwei79@gmail.com>
Subject: The AI parameter of tcp_highspeed.c (in 2.6.18)
Date: Mon, 29 May 2006 21:12:14 -0700
Message-ID: <7335583a0605292112l1f5a6ec3x4b1c1e4ae45688f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.206]:20678 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751472AbWE3EMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 00:12:15 -0400
Received: by nz-out-0102.google.com with SMTP id m7so648035nzf
        for <netdev@vger.kernel.org>; Mon, 29 May 2006 21:12:14 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi gurus,

    I am not sure if there is a problem in the additive increment (AI)
parameter of tcp_highspeed.c:

    When snd_cwnd is smaller than 38 and the connection is in
congestion avoidance phase (snd_cwnd > snd_ssthresh), the snd_cwnd
seems to stop growing. I guess the problem is in the function of
hstcp_cong_avoid (Ln 126~Ln 138 of tcp_highspeed.c):
--------------------------------
                if (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd) {
                        while (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd &&
                               ca->ai < HSTCP_AIMD_MAX - 1)
                                ca->ai++;
                } else if (tp->snd_cwnd < hstcp_aimd_vals[ca->ai].cwnd) {
                        while (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd &&
                               ca->ai > 0)
                                ca->ai--;
                }

                /* Do additive increase */
                if (tp->snd_cwnd < tp->snd_cwnd_clamp) {
                        tp->snd_cwnd_cnt += ca->ai;
--------------------------------
When snd_cwnd < snd_ssthresh, this part of code is effective. And
since snd_cwnd is smaller than 38, which is hstcp_aimd_vals[0].cwnd,
ca->ai will be equal to 0.

Hence, snd_cwnd_cnt will be unchanged for the rest of the connection.
As a result, snd_cwnd also freezes.

I guess we can add change the Line 138 to make the algorithm more reliable?

-                        tp->snd_cwnd_cnt += ca->ai;
+                       tp->snd_cwnd_cnt += (ca->ai+1);

Thanks.


-David
---------------------------------------------------------
Xiaoliang (David) Wei
http://davidwei.org    Graduate Student, Netlab, Caltech
======================================
