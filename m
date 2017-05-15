From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH] mdio: mux: fix device_node_continue.cocci warnings
Date: Mon, 15 May 2017 13:37:09 -0400
Message-ID: <CAC3K-4qtjNOfseuENeg2Q7-xKVCK-Ytz2wPQMcX_LiwPLuTAiw@mail.gmail.com>
References: <alpine.DEB.2.20.1705122252440.3416@hadrien> <20170512.122223.341607427763777325.davem@davemloft.net>
 <872f3980-9faa-718f-3260-9e4b22946140@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Network Development <netdev@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>, kbuild-all@01.org,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <872f3980-9faa-718f-3260-9e4b22946140@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 12, 2017 at 6:52 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 05/12/2017 09:22 AM, David Miller wrote:
>> From: Julia Lawall <julia.lawall@lip6.fr>
>> Date: Fri, 12 May 2017 22:54:23 +0800 (SGT)
>>
>>> Device node iterators put the previous value of the index variable, so an
>>> explicit put causes a double put.
>>  ...
>>> @@ -169,7 +169,6 @@ int mdio_mux_init(struct device *dev,
>>>              if (r) {
>>>                      mdiobus_free(cb->mii_bus);
>>>                      devm_kfree(dev, cb);
>>> -                    of_node_put(child_bus_node);
>>>              } else {
>>
>> I think we're instead simply missing a break; statement here.
>
> It's kind of questionable, if we have an error initializing one of our
> child MDIO bus controller (child from the perspective of the MDIO mux,
> boy this is getting complicated...), should we keep on going, or should
> we abort entirely and rollback what we have successfully registered?
>
> I don't think Julia's patch makes thing worse, in that if we had to
> rollback, we would not be doing this correctly now anyway.
>
> Jon, what do you think?

If every other case is fatal, then it is odd that this one is
permissive.  I think we should go 100% one way or the other.  So, the
options here are to:
1.  Encounter an error, unroll any mallocs, etc created by this entry,
but continue on to the next entry and return success if any are
created
2.  Encounter an error, unroll any mallocs, etc created by this entry
and any others that were created, and return an error
3.  Encounter an error, unroll any mallocs, etc created by this entry,
exit and return success if any are created

#1 would be the most accepting of any errors encountered
#2 would identify any poorly written DTs by breaking their currently
working functionality (though we should add some error messages to let
them know why)
#3 matches the suggestion by David Miller, and would be a hybrid of #1
and #2 in outcome

I would prefer #1, as I would not want to break something that was
currently working.  However, I think we should add much error logging
here to let people know their DT is hosed (instead of silently
working).  So, this would mean applying Julia's patch, and I'll do a
follow-on to change the breaks to continues and add the error logging
(assuming others agree with me).

Thanks,
Jon
