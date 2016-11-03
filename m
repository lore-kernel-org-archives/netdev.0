From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/sctp: use-after-free in __sctp_connect
Date: Thu, 3 Nov 2016 18:11:01 +0100
Message-ID: <CAAeHK+xxcV8XV1Pc2_eBrQWTDSp3ooc1LLX81jhCTCvk7hhaVg@mail.gmail.com>
References: <CAAeHK+wX8yxVTpmg-Ps7MKTD-x_HS3GgpzX6yfGh51cQE0oPjA@mail.gmail.com>
 <20161019165754.GD2958@localhost.localdomain> <CAAeHK+xaBVcZp7PfH-tYWaxs6rCiaNAivZj4xZLcawFShi6C1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+xaBVcZp7PfH-tYWaxs6rCiaNAivZj4xZLcawFShi6C1Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 2, 2016 at 11:42 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Wed, Oct 19, 2016 at 6:57 PM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
>> On Wed, Oct 19, 2016 at 02:25:24PM +0200, Andrey Konovalov wrote:
>>> Hi,
>>>
>>> I've got the following error report while running the syzkaller fuzzer:
>>>
>>> ==================================================================
>>> BUG: KASAN: use-after-free in __sctp_connect+0xabe/0xbf0 at addr
>>> ffff88006b1dc610
>>
>> Seems this is the same that Dmitry Vyukov had reported back in Jan 13th.
>> So far I couldn't identify the reason.
>> "Good" to know it's still there, thanks for reporting it.

Hi Marcelo,

So I've looked at the code.
As far as I understand, the problem is a race condition between
setsockopt(SCTP_SOCKOPT_CONNECTX) and shutdown on an sctp socket.
setsockopt() calls sctp_wait_for_connect(), which exits the for loop
on the sk->sk_shutdown & RCV_SHUTDOWN if clause, and then frees asoc
with sctp_association_put() and returns err = 0.
Then __sctp_connect() checks that err == 0 and reads asoc->assoc_id
from the freed asoc.
