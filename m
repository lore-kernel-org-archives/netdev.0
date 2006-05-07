From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [RFC] Proposed structure for Regulatory/Geographical Wireless
 database
Date: Sat, 06 May 2006 21:02:25 -0500
Message-ID: <445D5531.3000202@lwfinger.net>
References: <445BB22B.30505@lwfinger.net> <20060506013125.GL27667@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:36053 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750817AbWEGCCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 22:02:38 -0400
To: Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org,
	Faidon Liambotis <faidon@cube.gr>,
	Rick Jones <rick.jones2@hp.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Harald Welte <laforge@gnumonks.org>,
	Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060506013125.GL27667@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> On Fri, May 05, 2006 at 03:14:35PM -0500, Larry Finger wrote:
> 
> The driver may not know the country code, so there should be mechanism
> for user space to override this.

Do you think an environment variable would suffice, or do you propose another scheme?

>> * Checksum routines will be used to validate the data base. Such a simple 
>> scheme will not inhibit anyone with moderate skills from hacking the 
>> channel/power settings, but such hacking will require some effort.
> 
> I did not see this included in the example file. Did you have more
> detailed plans on how this would be done?

I was anticipating storing the output of an md5sum command in a separate file and comparing the 
contents of that file with one computed for the database when the daemon initializes. Is there a 
better scheme?

>> * Each channel in the resulting kernel data structure will have appropriate 
>> flags set indicating if it is to be used indoors, outdoors, or both. In 
>> addition, if the channel should be used only for passive scanning, a 
>> suitable flag will be set. In the 2.4 GHz band, a flag will indicate if it 
>> should be used for 802.11b, otherwise both b and g mode will be assumed. In 
>> the 5.0 GHz bands, a flag will be set if the channel is to conform with 
>> 802.11h or 802.11a standards.
> 
> 802.11h, radar detection, and DFS may need to be more complex than just
> a one-bit value of it being enabled. Countries may have different
> requirements for different areas related to 802.11h..

I'm afraid that I'm not quite ready for the complexity of 802.11h. Obviously, I need to do more reading.

>> The database consists of two sections. The first relates the Country Codes 
>> to a wireless group. The second section describes the channel parameters 
>> for the groups. Shown below is a fragment showing the Country Code - Group 
>> info for a few countries and the definitions for a few of the groups.
> 
> One way to compress this and possible make maintaining quite a bit
> easier would be to use two different set of groups: one for 2.4 GHz band
> and another one for 5 GHz band. Many countries share the same
> requirements for 2.4 GHz, but have different 5 GHz requirements.. This
> is not really a requirement, but could end up making this easier to use.

I don't think it makes too much difference, but I will consider your suggestion as the database 
starts to be more complete.

>> Number of Countries: 100
>> Number of Groups: 15
> 
> These are not really needed and unless a tool is used to update this
> file, they will most likely end up being out of sync at some point ;-).
> The parser can just read through the file twice if it need to know these
> numbers before parsing (though, that should not really be needed with
> dynamic data structures)..

Your point is well taken. I will remove that data.

>> # group Country Code    Description
>> #
>> 1       AT              Austria (Standard EU)
>> 1       DE              Germany (Standard EU)
>> 2       FRI             France Indoor (Not Guyana or La Reunion)
>> 3       FRO             France Outdoor (Not Guyana or La Reunion)
>> 4       FR1             French Departments of Guyana and La Reunion Indoor
>> 5       FR2             French Departments of Guyana and La Reunion Outdoor
> 
> Country code has to be two characters to fit into country IE..

This problem can be resolved for most of France as long as the driver supplies the country code and 
the indoor/outdoor flag. The table would then be:

Group 2         - France (Not Guyana or La Reunion)
#
bg        1 -   8       1                100    B
bg        9 -  13       1                100    I
bg        9 -  13       1                 10    O
h        36 -  48       4                200    I
h        52 -  64       4                200    IP
h       100 - 140       4               1000    IP
h       100 - 140       4               1000    OP

The details for the two unique French departments may have to come from the still undetermined 
802.11h information.

> AT and DE are a good example of possible use for different 2.4 GHz and 5
> GHz groups.. If I remember correctly, they have the same rules for 2.4
> GHz, but different for 5 GHz.. (unless--of course--they already changed
> them since I looked last time.. ;-)

Yes they have. Following the decision contained in 
http://europa.eu.int/eur-lex/lex/LexUriServ/LexUriServ.do?uri=CELEX:32005D0513:EN:NOT, all EU 
members and candidates are to adopt the same standards. Most already have. The differences are 
outlined in Appendix 3 of the the document downloaded through 
http://www.ero.dk/documentation/docs/docfiles.asp?docid=1622&wd=N. Things are changing so fast that 
the information for Greece has already changed. The bottom line is that for most EU countries, the 
requirements are identical.

>> # Ch. Range - Minimum and Maximum Channels for this range
>> # Ch. Spacing - Number of channels between adjacent entries
> 
> Other option would be to use start channel and number of channels.
> Channel spacing is also fixed in practice (1 for 2.4 GHz, 4 for 5 GHz),
> so it may not be needed here.

I decided that if I didn't use the channel spacing, someone would implement a 6 or 8 channel spacing 
in the 5 GHz bands.

>> # Power in mW EIRP
> 
> I would prefer to see the maximum TX power in dBm, not mW.

This change would have the advantage that the max power in Q5.2 format would fit in the u8 variable 
now allocated. I still have to check if any current driver is using this information.

>> # Flag Codes
>> # B - Both Indoor and Outdoor
>> # I - Indoor Only
>> # O - Outdoor Only
>> # P - Passive Scan Only
> 
> Some more flags may need to be added in the future. It looks like the
> format used here makes this trivial to extend.

I hope so.

Thanks for your thoughtful comments.

Larry

