From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: Re: [ethtool PATCH v1 2/2] ethtool:QSFP Plus/QSFP28 Diagnostics
 Information Support
Date: Sun, 26 Jun 2016 09:40:08 -0700
Message-ID: <CAKWE-XqgZ0hnqfLddg+ui4kTwZXzqKjq9vaXPod7fn=wBxByBQ@mail.gmail.com>
References: <1465860426-30387-3-git-send-email-vidya@cumulusnetworks.com> <1466933589.2504.42.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, bwh@kernel.org,
	David Miller <davem@davemloft.net>, bkenward@solarflare.com,
	daniel@iogearbox.net, Gal Pressman <galp@mellanox.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Dustin Byford <dustin@cumulusnetworks.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:35519 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbcFZQkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 12:40:10 -0400
Received: by mail-yw0-f172.google.com with SMTP id l125so137037695ywb.2
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2016 09:40:10 -0700 (PDT)
In-Reply-To: <1466933589.2504.42.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 26, 2016 at 2:33 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Mon, 2016-06-13 at 16:27 -0700, Vidya Sagar Ravipati wrote:
>> From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>>
>> This patch series provides following support
>> a) Reorganized fields based out of SFF-8024 fields i.e. Identifier/
>>    Encoding/Connector types which are common across SFP/SFP+ (SFF-8472)
>>    and QSFP+/QSFP28 (SFF-8436/SFF-8636) modules into sff-common files.
>> a) Support for diagnostics information for QSFP Plus/QSFP28 modules
>>    based on SFF-8436/SFF-8636
>
> Those two changes should be separate patches.
Will break down the patches
>
>> Standards for QSFP+/QSFP28
>> a) QSFP+/QSFP28 - SFF 8636 Rev 2.7 dated January 26,2016
>> b) SFF-8024 Rev 4.0 dated May 31, 2016
>>
>> Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>> Acked-by: Bert Kenward <bkenward@solarflare.com>
>> ---
>>  Makefile.am  |   2 +-
>>  ethtool.c    |   5 +
>>  internal.h   |   3 +
>>  qsfp.c       | 876 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>  qsfp.h       | 599 ++++++++++++++++++++++++++++++++++++++++
>>  sff-common.c | 255 +++++++++++++++++
>>  sff-common.h | 156 +++++++++++
>>  sfpid.c      | 103 +------
>>  8 files changed, 1899 insertions(+), 100 deletions(-)
>>  create mode 100644 qsfp.c
>>  create mode 100644 qsfp.h
>>  create mode 100644 sff-common.c
>>  create mode 100644 sff-common.h
>>
>> diff --git a/Makefile.am b/Makefile.am
>> index 6814bc9..1f3d767 100644
>> --- a/Makefile.am
>> +++ b/Makefile.am
>> @@ -13,7 +13,7 @@ ethtool_SOURCES += \
>>                 fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c \
>>                 pcnet32.c realtek.c tg3.c marvell.c vioc.c    \
>>                 smsc911x.c at76c50x-usb.c sfc.c stmmac.c      \
>> -               sfpid.c sfpdiag.c ixgbevf.c tse.c vmxnet3.c
>> +               sff-common.c sfpid.c sfpdiag.c ixgbevf.c tse.c vmxnet3.c qsfp.c
>>  endif
>>
>>  TESTS = test-cmdline test-features
>> diff --git a/ethtool.c b/ethtool.c
>> index 0cd0d4f..a0d48d1 100644
>> --- a/ethtool.c
>> +++ b/ethtool.c
>> @@ -3963,6 +3963,11 @@ static int do_getmodule(struct cmd_context *ctx)
>>                               sff8079_show_all(eeprom->data);
>>                               sff8472_show_all(eeprom->data);
>>                               break;
>> +                     case ETH_MODULE_SFF_8436:
>> +                     case ETH_MODULE_SFF_8636:
>> +                             sff8636_show_all(eeprom->data,
>> +                                   modinfo.eeprom_len);
>
> The last line here is wrongly indented, as are many other continuation
> lines.  ethtool code should be formatted just the same way David likes
> kernel networking code.
>
Ack, will do
> [...]
>> --- /dev/null
>> +++ b/qsfp.c
> [...]
>> +/* Channel Monitoring Fields */
>> +struct sff8636_channel_diags {
>> +
>> +     __u16 bias_cur;      /* Measured bias current in 2uA units */
>> +     __u16 rx_power;      /* Measured RX Power */
>> +     __u16 tx_power;      /* Measured TX Power */
>> +
>> +};
>
> There's no need for blank lines in this structure definition.
>
Ack
>> +/* Module Monitoring Fields */
>> +struct sff8636_diags {
>> +
>> +#define MAX_CHANNEL_NUM 4
>> +#define LWARN 0
>> +#define HWARN 1
>> +#define LALRM 2
>> +#define HALRM 3
>> +
>> +      /* Supports DOM */
>> +     __u8 supports_dom;
>> +     /* Supports alarm/warning thold */
>> +     __u8 supports_alarms;
>> +     /* RX Power: 0 = OMA, 1 = Average power */
>> +     __u8  rx_power_type;
>> +     /* TX Power: 0 = Not supported, 1 = Average power */
>> +     __u8  tx_power_type;
>> +     /* SFP voltage in 0.1mV units */
>> +     __u16 sfp_voltage;
>> +     /* SFP Temp in 16-bit signed 1/256 Celcius */
>> +     __s16 sfp_temp;
>> +     /* [4] tables are low/high warn, low/high alarm */
>> +     /* SFP voltage in 0.1mV units */
>> +     __u16 thresh_sfp_voltage[4];
>> +     /* SFP Temp in 16-bit signed 1/256 Celcius */
>> +     __s16 thresh_sfp_temp[4];
>> +     /* Measured bias current in 2uA units */
>> +     __u16 thresh_bias_cur[4];
>> +     /* Measured TX Power */
>> +     __u16 thresh_tx_power[4];
>> +     /* Measured RX Power */
>> +     __u16 thresh_rx_power[4];
>
> This looks very similar to sff8472_diags, only with the actual values
> separated from the arrays of thresholds.
>
> Can the structure and code be combined with sfpdiag.c, with the
> additional per-channel diagnostics being optional?

Diagnostic dom information in QSFP  has lot more information compared
to SFPs and as part of this checkin , basic dom information in qsfp which is
equivalent to sfp dom  is getting exposed as part of this checkin.

Here are list of fields (not complete)  which  are used for  debugging QSFP
issues, will be added for this structure in next patch sets
a) TX/RX output amplitude conttrol
b)  TX_DISABLE
b) TX_FAULT
c) TX CDR
d) RX CDR
e) RX output disable
f) Rate select option

Please let me know if it make sense to maintain the different structure
with above explanation  or whether it is required to be combined.

>> +     struct sff8636_channel_diags scd[MAX_CHANNEL_NUM];
>> +};
> [...]
>> --- /dev/null
>> +++ b/sff-common.c
> [...]
>> +double convert_mw_to_dbm(double mw)
>> +{
>> +     return (10. * log10(mw / 1000.)) + 30.;
>> +}
> [...]
>
> This is copied from sfpdiag.c, so you should make that file use it
> rather than a duplicate definition.
Ack, will cleanup

>
> Ben.
>
> --
>
> Ben Hutchings
> compatible: Gracefully accepts erroneous data from any source
