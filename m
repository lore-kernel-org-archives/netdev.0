From: Dave Kleikamp <dave.kleikamp@oracle.com>
Subject: Re: [PATCHv4 3/4] sparc64: Avoid irqsave/restore on vio.lock if in_softirq()
Date: Tue, 21 Oct 2014 18:56:01 -0500
Message-ID: <5446F291.1030400@oracle.com>
References: <20141021141647.GF15405@oracle.com> <CAGRGNgXvKJBhOE1z3=_gZkE=X94HnoAvTN6Zv5G1h8JuFfS8Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>
To: Julian Calaby <julian.calaby@gmail.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <CAGRGNgXvKJBhOE1z3=_gZkE=X94HnoAvTN6Zv5G1h8JuFfS8Ng@mail.gmail.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2014 05:35 PM, Julian Calaby wrote:
> Hi Sowmini,
> 
> On Wed, Oct 22, 2014 at 1:16 AM, Sowmini Varadhan
> <sowmini.varadhan@oracle.com> wrote:
>> For NAPIfied drivers , there is no need to
>> synchronize by doing irqsave/restore on vio.lock in the I/O
>> path.
>>
>> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>> ---
>>  arch/sparc/kernel/viohs.c | 8 +++++---
>>  1 file changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/sparc/kernel/viohs.c b/arch/sparc/kernel/viohs.c
>> index 7ef081a..d731586 100644
>> --- a/arch/sparc/kernel/viohs.c
>> +++ b/arch/sparc/kernel/viohs.c
>> @@ -747,10 +747,11 @@ EXPORT_SYMBOL(vio_ldc_free);
>>
>>  void vio_port_up(struct vio_driver_state *vio)
>>  {
>> -       unsigned long flags;
>> +       unsigned long flags = 0;
> 
> Is gcc not smart enough to know that this variable isn't used before
> it's set? (I assume it isn't used elsewhere in this function)

It probably assumes in_softirq() might evaluate differently in the each
case.

> 
>>         int err, state;
>>
>> -       spin_lock_irqsave(&vio->lock, flags);
>> +       if (!in_softirq())
>> +               spin_lock_irqsave(&vio->lock, flags);
>>
>>         state = ldc_state(vio->lp);
>>
>> @@ -777,7 +778,8 @@ void vio_port_up(struct vio_driver_state *vio)
>>                 mod_timer(&vio->timer, expires);
>>         }
>>
>> -       spin_unlock_irqrestore(&vio->lock, flags);
>> +       if (!in_softirq())
>> +               spin_unlock_irqrestore(&vio->lock, flags);
>>  }
>>  EXPORT_SYMBOL(vio_port_up);
> 
> Thanks,
> 
