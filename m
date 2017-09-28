From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of net/ipv4/tcp_input.c
Date: Thu, 28 Sep 2017 16:36:58 -0700
Message-ID: <CAK6E8=eju-MgROynJXntRCQ4KtXZ+qrgQC02bGJ27rp1wMmUjg@mail.gmail.com>
References: <20170921014620.GA20906@castle> <CAK6E8=eBZ6XhRg7ihoQ_2=4bTk1RSdxT2zJ_Z7-4X-HzNeaiQQ@mail.gmail.com>
 <CAK6E8=c3mNnjuWDaA8rjnCjn8mAih=ReQiZwGUgB5X2xrjaRiA@mail.gmail.com> <2325466.Xo6SG5M5hd@natalenko.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Roman Gushchin <guro@fb.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Oleksandr Natalenko <oleksandr@natalenko.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:50418 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750821AbdI1Xhk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 19:37:40 -0400
Received: by mail-wm0-f45.google.com with SMTP id u138so268117wmu.5
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 16:37:40 -0700 (PDT)
In-Reply-To: <2325466.Xo6SG5M5hd@natalenko.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 28, 2017 at 1:14 AM, Oleksandr Natalenko
<oleksandr@natalenko.name> wrote:
> Hi.
>
> Won't tell about panic in tcp_sacktag_walk() since I cannot trigger it
> intentionally, but setting net.ipv4.tcp_retrans_collapse to 0 *does not* =
fix
> warning in tcp_fastretrans_alert() for me.

Hi Oleksandr: no retrans_collapse should not matter for that warning
in tcp_fstretrans_alert(). the warning as I explained earlier is
likely false. Neal and I are more concerned the panic in
tcp_sacktag_walk. This is just a blind shot but thx for retrying.

We can submit a one-liner to remove the fast retrans warning but want
to nail the bigger issue first.

>
> On st=C5=99eda 27. z=C3=A1=C5=99=C3=AD 2017 2:18:32 CEST Yuchung Cheng wr=
ote:
>> On Tue, Sep 26, 2017 at 5:12 PM, Yuchung Cheng <ycheng@google.com> wrote=
:
>> > On Tue, Sep 26, 2017 at 6:10 AM, Roman Gushchin <guro@fb.com> wrote:
>> >>> On Wed, Sep 20, 2017 at 6:46 PM, Roman Gushchin <guro@fb.com> wrote:
>> >>> > > Hello.
>> >>> > >
>> >>> > > Since, IIRC, v4.11, there is some regression in TCP stack result=
ing
>> >>> > > in the
>> >>> > > warning shown below. Most of the time it is harmless, but rarely=
 it
>> >>> > > just
>> >>> > > causes either freeze or (I believe, this is related too) panic i=
n
>> >>> > > tcp_sacktag_walk() (because sk_buff passed to this function is
>> >>> > > NULL).
>> >>> > > Unfortunately, I still do not have proper stacktrace from panic,=
 but
>> >>> > > will try to capture it if possible.
>> >>> > >
>> >>> > > Also, I have custom settings regarding TCP stack, shown below as
>> >>> > > well. ifb is used to shape traffic with tc.
>> >>> > >
>> >>> > > Please note this regression was already reported as BZ [1] and a=
s a
>> >>> > > letter to ML [2], but got neither attention nor resolution. It i=
s
>> >>> > > reproducible for (not only) me on my home router since v4.11 til=
l
>> >>> > > v4.13.1 incl.
>> >>> > >
>> >>> > > Please advise on how to deal with it. I'll provide any additiona=
l
>> >>> > > info if
>> >>> > > necessary, also ready to test patches if any.
>> >>> > >
>> >>> > > Thanks.
>> >>> > >
>> >>> > > [1] https://bugzilla.kernel.org/show_bug.cgi?id=3D195835
>> >>> > > [2]
>> >>> > > https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__www.spini=
cs.ne
>> >>> > > t_lists_netdev_msg436158.html&d=3DDwIBaQ&c=3D5VD0RTtNlTh3ycd41b3=
MUw&r=3DjJ
>> >>> > > YgtDM7QT-W-Fz_d29HYQ&m=3DMDDRfLG5DvdOeniMpaZDJI8ulKQ6PQ6OX_1YtRs=
iTMA&s
>> >>> > > =3D-n3dGZw-pQ95kMBUfq5G9nYZFcuWtbTDlYFkcvQPoKc&e=3D>>> >
>> >>> > We're experiencing the same problems on some machines in our fleet=
.
>> >>> > Exactly the same symptoms: tcp_fastretrans_alert() warnings and
>> >>> > sometimes panics in tcp_sacktag_walk().
>> >>
>> >>> > Here is an example of a backtrace with the panic log:
>> >> Hi Yuchung!
>> >>
>> >>> do you still see the panics if you disable RACK?
>> >>> sysctl net.ipv4.tcp_recovery=3D0?
>> >>
>> >> No, we haven't seen any crash since that.
>> >
>> > I am out of ideas how RACK can potentially cause tcp_sacktag_walk to
>> > take an empty skb :-( Do you have stack trace or any hint on which cal=
l
>> > to tcp-sacktag_walk triggered the panic? internally at Google we never
>> > see that.
>>
>> hmm something just struck me: could you try
>> sysctl net.ipv4.tcp_recovery=3D1 net.ipv4.tcp_retrans_collapse=3D0
>> and see if kernel still panics on sack processing?
>>
>> >>> also have you experience any sack reneg? could you post the output o=
f
>> >>> ' nstat |grep -i TCP' thanks
>> >>
>> >> hostname        TcpActiveOpens                  2289680            0.=
0
>> >> hostname        TcpPassiveOpens                 3592758            0.=
0
>> >> hostname        TcpAttemptFails                 746910             0.=
0
>> >> hostname        TcpEstabResets                  154988             0.=
0
>> >> hostname        TcpInSegs                       16258678255        0.=
0
>> >> hostname        TcpOutSegs                      46967011611        0.=
0
>> >> hostname        TcpRetransSegs                  13724310           0.=
0
>> >> hostname        TcpInErrs                       2                  0.=
0
>> >> hostname        TcpOutRsts                      9418798            0.=
0
>> >> hostname        TcpExtEmbryonicRsts             2303               0.=
0
>> >> hostname        TcpExtPruneCalled               90192              0.=
0
>> >> hostname        TcpExtOfoPruned                 57274              0.=
0
>> >> hostname        TcpExtOutOfWindowIcmps          3                  0.=
0
>> >> hostname        TcpExtTW                        1164705            0.=
0
>> >> hostname        TcpExtTWRecycled                2                  0.=
0
>> >> hostname        TcpExtPAWSEstab                 159                0.=
0
>> >> hostname        TcpExtDelayedACKs               209207209          0.=
0
>> >> hostname        TcpExtDelayedACKLocked          508571             0.=
0
>> >> hostname        TcpExtDelayedACKLost            1713248            0.=
0
>> >> hostname        TcpExtListenOverflows           625                0.=
0
>> >> hostname        TcpExtListenDrops               625                0.=
0
>> >> hostname        TcpExtTCPHPHits                 9341188489         0.=
0
>> >> hostname        TcpExtTCPPureAcks               1434646465         0.=
0
>> >> hostname        TcpExtTCPHPAcks                 5733614672         0.=
0
>> >> hostname        TcpExtTCPSackRecovery           3261698            0.=
0
>> >> hostname        TcpExtTCPSACKReneging           12203              0.=
0
>> >> hostname        TcpExtTCPSACKReorder            433189             0.=
0
>> >> hostname        TcpExtTCPTSReorder              22694              0.=
0
>> >> hostname        TcpExtTCPFullUndo               45092              0.=
0
>> >> hostname        TcpExtTCPPartialUndo            22016              0.=
0
>> >> hostname        TcpExtTCPLossUndo               2150040            0.=
0
>> >> hostname        TcpExtTCPLostRetransmit         60119              0.=
0
>> >> hostname        TcpExtTCPSackFailures           2626782            0.=
0
>> >> hostname        TcpExtTCPLossFailures           182999             0.=
0
>> >> hostname        TcpExtTCPFastRetrans            4334275            0.=
0
>> >> hostname        TcpExtTCPSlowStartRetrans       3453348            0.=
0
>> >> hostname        TcpExtTCPTimeouts               1070997            0.=
0
>> >> hostname        TcpExtTCPLossProbes             2633545            0.=
0
>> >> hostname        TcpExtTCPLossProbeRecovery      941647             0.=
0
>> >> hostname        TcpExtTCPSackRecoveryFail       336302             0.=
0
>> >> hostname        TcpExtTCPRcvCollapsed           461354             0.=
0
>> >> hostname        TcpExtTCPAbortOnData            349196             0.=
0
>> >> hostname        TcpExtTCPAbortOnClose           3395               0.=
0
>> >> hostname        TcpExtTCPAbortOnTimeout         51201              0.=
0
>> >> hostname        TcpExtTCPMemoryPressures        2                  0.=
0
>> >> hostname        TcpExtTCPSpuriousRTOs           2120503            0.=
0
>> >> hostname        TcpExtTCPSackShifted            2613736            0.=
0
>> >> hostname        TcpExtTCPSackMerged             21358743           0.=
0
>> >> hostname        TcpExtTCPSackShiftFallback      8769387            0.=
0
>> >> hostname        TcpExtTCPBacklogDrop            5                  0.=
0
>> >> hostname        TcpExtTCPRetransFail            843                0.=
0
>> >> hostname        TcpExtTCPRcvCoalesce            949068035          0.=
0
>> >> hostname        TcpExtTCPOFOQueue               470118             0.=
0
>> >> hostname        TcpExtTCPOFODrop                9915               0.=
0
>> >> hostname        TcpExtTCPOFOMerge               9                  0.=
0
>> >> hostname        TcpExtTCPChallengeACK           90                 0.=
0
>> >> hostname        TcpExtTCPSYNChallenge           3                  0.=
0
>> >> hostname        TcpExtTCPFastOpenActive         2089               0.=
0
>> >> hostname        TcpExtTCPSpuriousRtxHostQueues  896596             0.=
0
>> >> hostname        TcpExtTCPAutoCorking            547386735          0.=
0
>> >> hostname        TcpExtTCPFromZeroWindowAdv      28757              0.=
0
>> >> hostname        TcpExtTCPToZeroWindowAdv        28761              0.=
0
>> >> hostname        TcpExtTCPWantZeroWindowAdv      322431             0.=
0
>> >> hostname        TcpExtTCPSynRetrans             3026               0.=
0
>> >> hostname        TcpExtTCPOrigDataSent           40976870977        0.=
0
>> >> hostname        TcpExtTCPHystartTrainDetect     453920             0.=
0
>> >> hostname        TcpExtTCPHystartTrainCwnd       11586273           0.=
0
>> >> hostname        TcpExtTCPHystartDelayDetect     10943              0.=
0
>> >> hostname        TcpExtTCPHystartDelayCwnd       763554             0.=
0
>> >> hostname        TcpExtTCPACKSkippedPAWS         30                 0.=
0
>> >> hostname        TcpExtTCPACKSkippedSeq          218                0.=
0
>> >> hostname        TcpExtTCPWinProbe               2408               0.=
0
>> >> hostname        TcpExtTCPKeepAlive              213768             0.=
0
>> >> hostname        TcpExtTCPMTUPFail               69                 0.=
0
>> >> hostname        TcpExtTCPMTUPSuccess            8811               0.=
0
>> >>
>> >> Thanks!
>
>
