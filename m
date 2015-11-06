From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [RFC PATCH 2/2] net: mvneta: Add naive RSS support
Date: Fri, 06 Nov 2015 21:53:40 +0100
Message-ID: <87y4ea7stn.fsf@free-electrons.com>
References: <1446834911-29910-1-git-send-email-gregory.clement@free-electrons.com>
	<1446834911-29910-3-git-send-email-gregory.clement@free-electrons.com>
	<CAPv3WKecZuSfk4LpCehWoijiA6Ea306qn5iyNbg4TucYuOZauw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKecZuSfk4LpCehWoijiA6Ea306qn5iyNbg4TucYuOZauw@mail.gmail.com>
	(Marcin Wojtas's message of "Fri, 6 Nov 2015 20:15:31 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcin,
 
[...]

>> +static int  mvneta_config_rss(struct mvneta_port *pp)
>> +{
>> +       int cpu;
>> +       u32 val;
>> +
>> +       netif_tx_stop_all_queues(pp->dev);
>> +
>> +       /* Mask all ethernet port interrupts */
>> +       mvreg_write(pp, MVNETA_INTR_NEW_MASK, 0);
>
> Shouldn't the interrupts be masked on each online cpu? There is percpu
> unmask function (mvneta_percpu_unmask_interrupt), so maybe ther should
> be also mvneta_percpu_mask_interrupt. With this masking should look
> like below:
>
>      for_each_online_cpu(cpu)
>                smp_call_function_single(cpu, mvneta_percpu_unmask_interrupt,
>                                         pp, true);

Indeed you are right, however I am a bit surprised to not had had issue
cause by this. I will fix it.

>
>> +       mvreg_write(pp, MVNETA_INTR_OLD_MASK, 0);
>> +       mvreg_write(pp, MVNETA_INTR_MISC_MASK, 0);
>> +
>> +       /* We have to synchronise on the napi of each CPU */
>> +       for_each_online_cpu(cpu) {
>> +               struct mvneta_pcpu_port *pcpu_port =
>> +                       per_cpu_ptr(pp->ports, cpu);
>> +
>> +               napi_synchronize(&pcpu_port->napi);
>> +               napi_disable(&pcpu_port->napi);
>> +       }
>> +
>> +       pp->rxq_def = pp->indir[0];
>> +
>> +       /* update unicast mapping */
>> +       mvneta_set_rx_mode(pp->dev);
>> +
>> +       /* Update val of portCfg register accordingly with all RxQueue types */
>> +       val = MVNETA_PORT_CONFIG_DEFL_VALUE(pp->rxq_def);
>> +       mvreg_write(pp, MVNETA_PORT_CONFIG, val);
>> +
>> +       /* Update the elected CPU matching the new rxq_def */
>> +       mvneta_percpu_elect(pp);
>> +
>> +       /* We have to synchronise on the napi of each CPU */
>> +       for_each_online_cpu(cpu) {
>> +               struct mvneta_pcpu_port *pcpu_port =
>> +                       per_cpu_ptr(pp->ports, cpu);
>> +
>> +               napi_enable(&pcpu_port->napi);
>> +       }
>> +
>
> rxq_def changed, but txq vs CPU mapping remained as in the beginning -
> is it intentional?

txq vs CPU mapping is change in the mvneta_percpu_elect() function.

Thanks for this prompt review

Gregory

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
