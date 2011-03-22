From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH 0/7] TCP CUBIC Hystart fixes
Date: Tue, 22 Mar 2011 12:34:56 +0100
Message-ID: <20110322113456.GA21254@xanadu.blop.info>
References: <20110314175211.788224699@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S\. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:50354 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220Ab1CVLfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 07:35:44 -0400
Content-Disposition: inline
In-Reply-To: <20110314175211.788224699@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/03/11 at 10:52 -0700, Stephen Hemminger wrote:
> This is the merge of my patches and recent update Sangtae.
> It addresses the problems reported by Lucas Nussbaum that Hystart cau=
ses
> poor startup performance over links with lots of buffering.

Hi,

I've tested the patches, and they work fine.

Here are some results (gigabit link, RTT=3D11ms).

Without the patches, hystart disabled:
 Segments (cwnd, ssthresh)
   2500 ++-----------+-------------+------------+-------------+--------=
---++
        +            +             +            +          snd_cwnd ***=
*** +
        |                                              snd_ssthresh ###=
### |
   2000 ++       *************************************************     =
   ++
        |       **                                                     =
    |
        |       *                                                      =
    |
        |       *                                                      =
    |
   1500 ++      *                                                      =
   ++
        |       *                                                      =
    |
        |       *                                                      =
    |
   1000 ++      *                                                      =
   ++
        |      **                                                      =
    |
        |      *                                                       =
    |
        |      *                                                       =
    |
    500 ++     *                                                       =
   ++
        |     **                                                       =
    |
        +    **      +             +            +             +        =
    +
      0 ++-***####################################################-----=
---++
        0           0.5            1           1.5            2        =
   2.5
                                  time (seconds)

Without the patches, hystart enabled:
 Segments (cwnd, ssthresh)
   300 ++------------+------------+-------------+------------+---------=
---++
       +             +            +             +          snd_cwnd ***=
*** +
       |                                            ***snd_ssthresh ###=
### |
   250 ++                     ***********************                  =
   ++
       |     ******************###################################     =
    |
       |     *                                                         =
    |
   200 ++    *                                                         =
   ++
       |     *                                                         =
    |
   150 ++    *                                                         =
   ++
       |     *                                                         =
    |
       |     *                                                         =
    |
   100 ++   **                                                         =
   ++
       |    *#                                                         =
    |
       |    *#                                                         =
    |
    50 ++   *#                                                         =
   ++
       |   **#                                                         =
    |
       +  ** #       +            +             +            +         =
    +
     0 ++-*###-------+------------+-------------+------------+---------=
---++
       0            0.5           1            1.5           2         =
   2.5
                                  time (seconds)

Note how slow start ends very early (~ 230 segments), resulting in poor=
 performance.

With the patches, hystart enabled, run 1:
 Segments (cwnd, ssthresh)
   2500 ++-----+-------+------+-------+------+-------+------+-------+--=
---++
        +      +       +      +       +      +       +     snd_cwnd ***=
*** +
        |                                              snd_ssthresh ###=
### |
   2000 ++   ********************************************************* =
   ++
        |    *                                                         =
    |
        |    *                                                         =
    |
        |    *                                                         =
    |
   1500 ++   *                                                         =
   ++
        |    *                                                         =
    |
        |   **                                                         =
    |
   1000 ++  *                                                          =
   ++
        |   *                                                          =
    |
        |   *                                                          =
    |
        |   *                                                          =
    |
    500 ++  *                                                          =
   ++
        |  **                                                          =
    |
        +  *   +       +      +       +      +       +      +       +  =
    +
      0 ++**##########################################################-=
---++
        0     0.5      1     1.5      2     2.5      3     3.5      4  =
   4.5
                                  time (seconds)

There's no perceived delay increase, but also no losses. The NIC sends =
data at
line rate without congestion. we don't exit slow start, but that's fine=
:

With the patch, hystart enabled, run 2: (that's the most frequent situa=
tion)
 Segments (cwnd, ssthresh)
   2500 ++-----+-------+------+-------+------+-------+------+-------+--=
---++
        +      +       +      +       +      +       +     snd_cwnd ***=
*** +
        |                                              snd_ssthresh ###=
### |
   2000 ++    ******************************************************** =
   ++
        |     *#                                                       =
    |
        |     *#                                                       =
    |
        |     *#                                                       =
    |
   1500 ++    *#                                                       =
   ++
        |     *#                                                       =
    |
        |     *#                                                       =
    |
   1000 ++   **#                                                       =
   ++
        |    * #                                                       =
    |
        |    * #                                                       =
    |
        |    * #                                                       =
    |
    500 ++  ** #                                                       =
   ++
        |   *  #                                                       =
    |
        +  **  #       +      +       +      +       +      +       +  =
    +
      0 ++**####-------+------+-------+------+-------+------+-------+--=
---++
        0     0.5      1     1.5      2     2.5      3     3.5      4  =
   4.5
                                  time (seconds)

Hystart detects a delay increase, so we exit slow start, but at a reaso=
nable point.
Hystart works fine in that case. (no impact on performance).

With the patch, hystart enabled, run 3:
 Segments (cwnd, ssthresh)
   2500 ++-----+-------+------+-------+------+-------+------+-------+--=
---++
        +      +       +      +       +      +       +     snd_cwnd ***=
*** +
        |                                              snd_ssthresh ###=
### |
   2000 ++     ******************************************************* =
   ++
        |      *                                                       =
    |
        |     **                                                       =
    |
        |     *                                                        =
    |
   1500 ++   **####################################################### =
   ++
        |    *#                                                        =
    |
        |    *#                                                        =
    |
   1000 ++   *#                                                        =
   ++
        |    *#                                                        =
    |
        |   **#                                                        =
    |
        |   * #                                                        =
    |
    500 ++  * #                                                        =
   ++
        |   * #                                                        =
    |
        +  ** #+       +      +       +      +       +      +       +  =
    +
      0 ++**###+-------+------+-------+------+-------+------+-------+--=
---++
        0     0.5      1     1.5      2     2.5      3     3.5      4  =
   4.5
                                  time (seconds)

Hystart causes slow start to end a bit too early, but late enough not t=
o affect
performance significantly. Hystart behaves fine in that case too.


Tested-By: Lucas Nussbaum <lucas.nussbaum@loria.fr>
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
