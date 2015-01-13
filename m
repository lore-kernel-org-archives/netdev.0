From: "Banerjee, Debabrata" <dbanerje@akamai.com>
Subject: Re: [PATCH] tcp: Fix RFC reference in comment
Date: Tue, 13 Jan 2015 18:17:50 -0500
Message-ID: <D0DB041A.44371%dbanerje@akamai.com>
References: <1421183431-29915-1-git-send-email-dbanerje@akamai.com>
 <CAK6E8=d6NMZjyH1JFoJX_ioAdQNYCAvH-G3ja9fScwW9u2=NFQ@mail.gmail.com>
 <D0DAFA79.4435F%dbanerje@akamai.com>
 <CABrhC0m=aPO=OcfK_gTusHz7CU9OUeXAHoqUDaVTGLDiQnL56Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABrhC0m=aPO=OcfK_gTusHz7CU9OUeXAHoqUDaVTGLDiQnL56Q@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/13/15, 5:01 PM, "John Heffner" <johnwheffner@gmail.com> wrote:

>On Tue, Jan 13, 2015 at 4:42 PM, Banerjee, Debabrata
><dbanerje@akamai.com> wrote:
>> On 1/13/15, 4:36 PM, "Yuchung Cheng" <ycheng@google.com> wrote:
>>
>>>RFC2861 resets the cwnd like in RFC2581, but the rest of the code
>>>implements RFC2861. So I think the current comment is fine.
>>
>>
>> No RFC2861 is an experimental RFC that's implemented in
>> tcp_cwnd_application_limited(). RFC2861 Recommends reducing the cwnd by
>> averaging the current cwnd and the used cwnd as the new cwnd.
>>
>>
>> RFC2581 4.1 Says to set cwnd to initial cwnd if more than one rto has
>> passed since the last send. This is what is implemented in the function
>> above.
>
>Look at the code a little closer -- it's decaying cwnd based on number
>of timeouts as described in 2861, not resetting to IW as recommended
>in 2581.
>
>  -John


You're right it's not RFC2581 I was partially misled by the comment
(reset/restart window), but it doesn't appear to be doing what rfc2861 3.2
says either:

           For i=1  To (tcpnow - T_last)/RTO
	win =  min(cwnd, receiver's declared max window)
	cwnd =  max(win/2, MSS)


Versus:

u32 restart_cwnd = tcp_init_cwnd(tp, dst);

restart_cwnd = min(restart_cwnd, cwnd);

	while ((delta -= inet_csk(sk)->icsk_rto) > 0 && cwnd > restart_cwnd)
	cwnd >>= 1;
	tp->snd_cwnd = max(cwnd, restart_cwnd);


It's not using receiver window, it's using cwnd/init_cwnd, it should at
least be using tp->snd_wnd, no?.


I stumbled onto this because it looks like tcp_cwnd_application_limited()
doesn't execute when it should, because tp->snd_cwnd_stamp is being
touched much more often than in rfc2861 3.2. Something seems not right
here...

-Debabrata
