From: =?utf-8?Q?H=C3=A5kon_Bugge?= <haakon.bugge@oracle.com>
Subject: Re: [PATCH net] rds: Make sure updates to cp_send_gen can be observed
Date: Thu, 20 Jul 2017 13:24:11 +0200
Message-ID: <0EE3287D-4537-4B43-9899-FCC2F50A666F@oracle.com>
References: <20170720102855.21961-1-Haakon.Bugge@oracle.com> <20170720110254.GB14156@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        OFED mailing list <linux-rdma@vger.kernel.org>,
        rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170720110254.GB14156@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On 20 Jul 2017, at 13:02, Sowmini Varadhan <sowmini.varadhan@oracle.com> wrote:
> 
> On (07/20/17 12:28), H??kon Bugge wrote:
>> cp->cp_send_gen is treated as a normal variable, although it may be
>> used by different threads.
> 
> I'm confused by that assertion. If you look at the comments right
> above the change in your patch, there is a note that 
> acquire_in_xmit/release_in_xmit are the synchronization/serialization 
> points.
> 
> Can you please clarify?

The way the original code works, is that it is allowed for the compiler to keep the value of “cp->cp_send_gen + 1” in a register. The compiler has no requirement to store this value to memory, before leaving the function or calling another one.

Further, said register can be used in the comparison outside the acquire_in_xmit/release_in_xmit, at which point another thread may have changed its value.


Thxs, Håkon

> 
>> --- a/net/rds/send.c
>> +++ b/net/rds/send.c
>> @@ -170,8 +170,8 @@ int rds_send_xmit(struct rds_conn_path *cp)
>> 	 * The acquire_in_xmit() check above ensures that only one
>> 	 * caller can increment c_send_gen at any time.
>> 	 */
>> -	cp->cp_send_gen++;
>> -	send_gen = cp->cp_send_gen;
>> +	send_gen = READ_ONCE(cp->cp_send_gen) + 1;
>> +	WRITE_ONCE(cp->cp_send_gen, send_gen);
>> 
> 
> --Sowmini
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
